import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion_kind.dart';
import 'package:cyclerisk/features/route_search/data/services/place_search_service.dart';
import 'package:cyclerisk/features/route_search/data/services/recent_places_repository.dart';
import 'package:cyclerisk/features/route_search/presentation/screens/map_location_picker_screen.dart';
import 'package:cyclerisk/features/route_search/presentation/widgets/origin_picker_sheet.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final PlaceSearchService _placeSearchService = PlaceSearchService();
  final RouteApiService _routeApiService = RouteApiService();
  final RecentPlacesRepository _recentPlacesRepository = RecentPlacesRepository();

  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  late final FocusNode _originFocusNode;
  late final FocusNode _destinationFocusNode;
  Timer? _originDebounce;
  Timer? _destinationDebounce;

  PlaceSuggestion? _selectedOrigin;
  PlaceSuggestion? _selectedDestination;
  List<PlaceSuggestion> _originSuggestions = const [];
  List<PlaceSuggestion> _destinationSuggestions = const [];
  List<PlaceSuggestion> _recentDestinations = const [];
  List<PlaceSuggestion> _recentOrigins = const [];
  bool _loadingOriginSuggestions = false;
  bool _loadingDestinationSuggestions = false;
  bool _loadingHistory = true;
  bool _loadingRouteOptions = false;
  bool _destinationShortcutsExpanded = false;
  String? _errorMessage;
  bool _loadedRouteArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedRouteArguments) {
      return;
    }
    _loadedRouteArguments = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PlaceSuggestion) {
      final l10n = appL10n(context);
      _selectedDestination = args;
      _destinationController.text = args.localizedTitle(l10n);
    }
  }

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();
    _originFocusNode = FocusNode();
    _destinationFocusNode = FocusNode();
    _destinationFocusNode.addListener(_onDestinationFocusChanged);
    _loadHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncCurrentLocation(force: true);
    });
  }

  @override
  void dispose() {
    _originDebounce?.cancel();
    _destinationDebounce?.cancel();
    _destinationFocusNode.removeListener(_onDestinationFocusChanged);
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onDestinationFocusChanged() {
    if (!mounted) return;

    if (_destinationFocusNode.hasFocus) {
      setState(() => _destinationShortcutsExpanded = true);
      return;
    }

    // Delay collapse so taps on shortcut tiles register before removal.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _destinationFocusNode.hasFocus) return;
      setState(() => _destinationShortcutsExpanded = false);
    });
  }

  Future<void> _syncCurrentLocation({bool force = false}) async {
    final l10n = appL10n(context);
    final locationProvider = context.read<LocationProvider>();

    if (force || locationProvider.currentLocation == null) {
      final granted = await locationProvider.ensureAccess(
        context,
        showRationale: force,
      );
      if (!granted && !mounted) {
        return;
      }
    } else if (!locationProvider.hasLocationAccess) {
      await locationProvider.refreshAccessStatus();
    }

    if (locationProvider.currentLocation == null && locationProvider.hasLocationAccess) {
      await locationProvider.getCurrentLocation();
    }

    final location = locationProvider.currentLocation;
    if (!mounted || location == null) {
      return;
    }

    final origin = PlaceSuggestion.currentLocation(
      GeoPoint(lat: location.latitude, lng: location.longitude),
    );
    setState(() {
      if (force || _selectedOrigin == null) {
        _selectedOrigin = origin;
      }
      if (force ||
          _originController.text.trim().isEmpty ||
          _selectedOrigin?.kind == PlaceSuggestionKind.currentLocation) {
        _originController.text = origin.localizedTitle(l10n);
      }
    });
  }

  Future<void> _loadHistory() async {
    final token = context.read<AuthProvider>().accessToken;
    final results = await Future.wait([
      _recentPlacesRepository.loadDestinations(token),
      _recentPlacesRepository.loadOrigins(token),
    ]);

    if (!mounted) return;

    setState(() {
      _recentDestinations = results[0];
      _recentOrigins = results[1];
      _loadingHistory = false;
    });
  }

  Future<void> _saveRouteHistory({
    required PlaceSuggestion origin,
    required PlaceSuggestion destination,
  }) async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      return;
    }

    final updated = await _recentPlacesRepository.saveRoutePlaces(
      accessToken: token,
      origin: origin,
      destination: destination,
    );

    if (!mounted) return;

    setState(() {
      _recentDestinations = updated.destinations;
      _recentOrigins = updated.origins;
    });
  }

  void _onOriginChanged(String value) {
    if (_selectedOrigin != null &&
        _selectedOrigin!.localizedTitle(appL10n(context)) != value.trim()) {
      _selectedOrigin = null;
    }
    _searchPlaces(value, isOrigin: true);
  }

  void _onDestinationChanged(String value) {
    if (_selectedDestination != null &&
        _selectedDestination!.localizedTitle(appL10n(context)) != value.trim()) {
      _selectedDestination = null;
    }
    _searchPlaces(value, isOrigin: false);
  }

  void _searchPlaces(String value, {required bool isOrigin}) {
    final debounce = isOrigin ? _originDebounce : _destinationDebounce;
    debounce?.cancel();

    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        if (isOrigin) {
          _originSuggestions = const [];
          _loadingOriginSuggestions = false;
        } else {
          _destinationSuggestions = const [];
          _loadingDestinationSuggestions = false;
        }
      });
      return;
    }

    final timer = Timer(const Duration(milliseconds: 420), () async {
      setState(() {
        if (isOrigin) {
          _loadingOriginSuggestions = true;
        } else {
          _loadingDestinationSuggestions = true;
        }
      });

      try {
        final token = context.read<AuthProvider>().accessToken;
        if (token == null || token.isEmpty) {
          if (!mounted) return;
          setState(
            () => _errorMessage =
                appL10n(context).pleaseSignInToCalculateRoutes,
          );
          return;
        }

        final current = context.read<LocationProvider>().currentLocation;
        final near = current == null
            ? null
            : GeoPoint(lat: current.latitude, lng: current.longitude);
        final suggestions = await _placeSearchService.searchPlaces(
          query,
          accessToken: token,
          near: near,
        );

        if (!mounted) return;

        setState(() {
          if (isOrigin) {
            _originSuggestions = suggestions;
          } else {
            _destinationSuggestions = suggestions;
          }
        });
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(
          () => _errorMessage = localizeApiError(appL10n(context), e),
        );
      } catch (_) {
        if (!mounted) return;
        setState(
          () => _errorMessage = appL10n(context).couldNotSearchPlaces,
        );
      } finally {
        if (mounted) {
          setState(() {
            if (isOrigin) {
              _loadingOriginSuggestions = false;
            } else {
              _loadingDestinationSuggestions = false;
            }
          });
        }
      }
    });

    if (isOrigin) {
      _originDebounce = timer;
    } else {
      _destinationDebounce = timer;
    }
  }

  void _selectPlace(PlaceSuggestion place, {required bool isOrigin}) {
    final l10n = appL10n(context);
    setState(() {
      if (isOrigin) {
        _selectedOrigin = place;
        _originController.text = place.localizedTitle(l10n);
        _originSuggestions = const [];
        _originFocusNode.unfocus();
      } else {
        _selectedDestination = place;
        _destinationController.text = place.localizedTitle(l10n);
        _destinationSuggestions = const [];
        _destinationFocusNode.unfocus();
        _destinationShortcutsExpanded = false;
      }
      _errorMessage = null;
    });
  }

  Future<void> _openOriginPicker() async {
    final l10n = appL10n(context);
    await OriginPickerSheet.show(
      context,
      recentOrigins: _recentOrigins,
      onSelectOrigin: (place) => _selectPlace(place, isOrigin: true),
      onAction: (action) async {
        switch (action) {
          case OriginPickerSheetAction.currentLocation:
            await _syncCurrentLocation(force: true);
            final origin = _selectedOrigin;
            if (origin != null) {
              _selectPlace(origin, isOrigin: true);
            }
          case OriginPickerSheetAction.mapPick:
            await _pickOnMap(isOrigin: true, title: l10n.chooseStartingPoint);
        }
      },
    );
  }

  Future<void> _pickOnMap({
    required bool isOrigin,
    required String title,
  }) async {
    if (!isOrigin) {
      _destinationShortcutsExpanded = false;
    }

    LatLng? initialCenter;
    final selected = isOrigin ? _selectedOrigin : _selectedDestination;
    if (selected != null) {
      initialCenter = LatLng(selected.point.lat, selected.point.lng);
    } else {
      final location = context.read<LocationProvider>().currentLocation;
      if (location != null) {
        initialCenter = LatLng(location.latitude, location.longitude);
      }
    }

    final picked = await Navigator.of(context).push<PlaceSuggestion>(
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          title: title,
          initialCenter: initialCenter,
        ),
      ),
    );

    if (picked == null || !mounted) return;
    _selectPlace(picked, isOrigin: isOrigin);
  }

  Future<PlaceSuggestion?> _resolveTypedDestination() async {
    if (_selectedDestination != null) {
      return _selectedDestination;
    }

    final query = _destinationController.text.trim();
    if (query.length < 3) {
      return null;
    }

    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }

    final current = context.read<LocationProvider>().currentLocation;
    final near = current == null
        ? null
        : GeoPoint(lat: current.latitude, lng: current.longitude);
    final suggestions = await _placeSearchService.searchPlaces(
      query,
      accessToken: token,
      near: near,
      limit: 1,
    );
    return suggestions.isEmpty ? null : suggestions.first;
  }

  Future<PlaceSuggestion?> _resolveTypedOrigin() async {
    if (_selectedOrigin != null) {
      return _selectedOrigin;
    }

    final query = _originController.text.trim();
    if (query.isEmpty ||
        query == appL10n(context).currentLocation ||
        _selectedOrigin?.kind == PlaceSuggestionKind.currentLocation) {
      await _syncCurrentLocation();
      return _selectedOrigin;
    }

    if (query.length < 3) {
      return null;
    }

    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }

    final current = context.read<LocationProvider>().currentLocation;
    final near = current == null
        ? null
        : GeoPoint(lat: current.latitude, lng: current.longitude);
    final suggestions = await _placeSearchService.searchPlaces(
      query,
      accessToken: token,
      near: near,
      limit: 1,
    );
    return suggestions.isEmpty ? null : suggestions.first;
  }

  Future<void> _openRouteOptions() async {
    final l10n = appL10n(context);
    final preference = context.read<AuthProvider>().defaultRoutePreference;
    final bikeProfile = context.read<BikeProfileProvider>().profile;
    setState(() {
      _loadingRouteOptions = true;
      _errorMessage = null;
    });

    try {
      final accessToken = context.read<AuthProvider>().accessToken;
      final origin = await _resolveTypedOrigin();
      final destination = await _resolveTypedDestination();

      if (origin == null) {
        throw Exception(l10n.chooseOriginWithCoordinates);
      }
      if (destination == null) {
        throw Exception(l10n.chooseDestinationFromSuggestions);
      }
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception(l10n.pleaseSignInToCalculateRoutes);
      }

      final result = await _routeApiService.getRouteOptions(
        origin: origin.point,
        destination: destination.point,
        accessToken: accessToken,
        originLabel: origin.localizedTitle(l10n),
        destinationLabel: destination.localizedTitle(l10n),
        preference: preference,
        bikeProfile: bikeProfile,
      );

      if (result.routes.isEmpty) {
        throw Exception(l10n.noRouteOptionsFound);
      }

      await _saveRouteHistory(origin: origin, destination: destination);
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamed(AppRoutes.routeResults, arguments: result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingRouteOptions = false);
      }
    }
  }

  bool _showDestinationShortcuts(AppLocalizations l10n) {
    return _destinationShortcutsExpanded &&
        _destinationController.text.trim().length < 3 &&
        _destinationSuggestions.isEmpty &&
        !_loadingDestinationSuggestions;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final canSearch =
        !_loadingRouteOptions &&
        _originController.text.trim().isNotEmpty &&
        _destinationController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.whereTo),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AutocompleteField(
                label: l10n.origin,
                hint: l10n.originHint,
                controller: _originController,
                focusNode: _originFocusNode,
                icon: Icons.my_location_rounded,
                suggestions: _originSuggestions,
                isLoading: _loadingOriginSuggestions,
                l10n: l10n,
                onChanged: _onOriginChanged,
                onSubmitted: (_) => _openRouteOptions(),
                onSelect: (place) => _selectPlace(place, isOrigin: true),
                trailing: IconButton(
                  tooltip: l10n.useCurrentLocation,
                  icon: const Icon(Icons.near_me_rounded),
                  color: AppColors.primary,
                  onPressed: _openOriginPicker,
                ),
              ),
              const SizedBox(height: 16),
              _AutocompleteField(
                label: l10n.destination,
                hint: l10n.destinationHint,
                controller: _destinationController,
                focusNode: _destinationFocusNode,
                icon: Icons.search_rounded,
                suggestions: _destinationSuggestions,
                isLoading: _loadingDestinationSuggestions,
                l10n: l10n,
                onChanged: _onDestinationChanged,
                onSubmitted: (_) => _openRouteOptions(),
                onSelect: (place) => _selectPlace(place, isOrigin: false),
                trailing: IconButton(
                  tooltip: l10n.setLocationOnMap,
                  icon: const Icon(Icons.map_outlined),
                  color: AppColors.primary,
                  onPressed: () => _pickOnMap(
                    isOrigin: false,
                    title: l10n.setLocationOnMap,
                  ),
                ),
              ),
              if (_showDestinationShortcuts(l10n)) ...[
                const SizedBox(height: 12),
                _DestinationShortcuts(
                  l10n: l10n,
                  loadingHistory: _loadingHistory,
                  recentDestinations: _recentDestinations,
                  onSelect: (place) => _selectPlace(place, isOrigin: false),
                  onPickOnMap: () => _pickOnMap(
                    isOrigin: false,
                    title: l10n.setLocationOnMap,
                  ),
                  onClear: () async {
                    final token = context.read<AuthProvider>().accessToken;
                    final cleared = await _recentPlacesRepository
                        .clearDestinations(token);
                    if (!mounted) return;
                    setState(() => _recentDestinations = cleared);
                  },
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.alertRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: canSearch ? _openRouteOptions : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loadingRouteOptions
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.seeRouteOptions,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationShortcuts extends StatelessWidget {
  const _DestinationShortcuts({
    required this.l10n,
    required this.loadingHistory,
    required this.recentDestinations,
    required this.onSelect,
    required this.onPickOnMap,
    required this.onClear,
  });

  final AppLocalizations l10n;
  final bool loadingHistory;
  final List<PlaceSuggestion> recentDestinations;
  final ValueChanged<PlaceSuggestion> onSelect;
  final VoidCallback onPickOnMap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(
              Icons.map_outlined,
              color: AppColors.navigationCyan,
            ),
            title: Text(
              l10n.setLocationOnMap,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(l10n.dragMapToAdjustPin),
            onTap: () {
              // Invoke immediately; parent delays panel collapse on unfocus.
              onPickOnMap();
            },
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentDestinations,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (recentDestinations.isNotEmpty)
                  TextButton(onPressed: onClear, child: Text(l10n.clear)),
              ],
            ),
          ),
          if (loadingHistory)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (recentDestinations.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.recentDestinationsEmpty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: recentDestinations
                    .map(
                      (destination) => ActionChip(
                        label: Text(destination.localizedTitle(l10n)),
                        backgroundColor: AppColors.background,
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        onPressed: () => onSelect(destination),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.suggestions,
    required this.isLoading,
    required this.l10n,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSelect,
    this.trailing,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<PlaceSuggestion> onSelect;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : trailing,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.3,
              ),
            ),
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: suggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.place_outlined,
                        color: AppColors.navigationCyan,
                      ),
                      title: Text(
                        suggestion.localizedTitle(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        suggestion.subtitleFor(l10n),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSelect(suggestion),
                    ),
                    if (index < suggestions.length - 1)
                      const Divider(height: 1, color: AppColors.divider),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
