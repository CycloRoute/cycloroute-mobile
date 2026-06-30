import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:cyclerisk/core/config/app_config.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/services/place_search_service.dart';

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({
    super.key,
    required this.title,
    this.initialCenter,
  });

  final String title;
  final LatLng? initialCenter;

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final MapController _mapController = MapController();
  final PlaceSearchService _placeSearchService = PlaceSearchService();

  LatLng? _selectedCenter;
  String? _addressLabel;
  bool _loadingAddress = false;
  Timer? _reverseGeocodeDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMap());
  }

  @override
  void dispose() {
    _reverseGeocodeDebounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    LatLng? center = widget.initialCenter;
    if (center == null) {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.currentLocation == null) {
        await locationProvider.getCurrentLocation();
      }
      final location = locationProvider.currentLocation;
      if (location != null) {
        center = LatLng(location.latitude, location.longitude);
      }
    }

    center ??= LatLng(-12.0464, -77.0428);
    if (!mounted) return;

    setState(() => _selectedCenter = center);
    _mapController.move(center, 15);
    _scheduleReverseGeocode(center);
  }

  void _onMapMoved(MapPosition position) {
    final center = position.center;
    if (center == null) {
      return;
    }
    setState(() => _selectedCenter = center);
    _scheduleReverseGeocode(center);
  }

  void _scheduleReverseGeocode(LatLng center) {
    _reverseGeocodeDebounce?.cancel();
    _reverseGeocodeDebounce = Timer(const Duration(milliseconds: 450), () {
      _reverseGeocode(center);
    });
  }

  Future<void> _reverseGeocode(LatLng center) async {
    setState(() => _loadingAddress = true);

    try {
      final token = context.read<AuthProvider>().accessToken;
      if (token == null || token.isEmpty) {
        throw StateError('missing access token');
      }

      final place = await _placeSearchService.reverseGeocode(
        GeoPoint(lat: center.latitude, lng: center.longitude),
        accessToken: token,
      );
      if (!mounted) return;
      setState(() => _addressLabel = place.title);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _addressLabel =
            '${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
      );
    } finally {
      if (mounted) {
        setState(() => _loadingAddress = false);
      }
    }
  }

  void _confirm() {
    final center = _selectedCenter;
    if (center == null) {
      return;
    }

    final point = GeoPoint(lat: center.latitude, lng: center.longitude);
    final label = _addressLabel?.trim();
    Navigator.of(context).pop(
      PlaceSuggestion.mapPick(
        point: point,
        label: label?.isNotEmpty == true
            ? label!
            : '${point.lat.toStringAsFixed(6)}, ${point.lng.toStringAsFixed(6)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final center = _selectedCenter ?? LatLng(-12.0464, -77.0428);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: center,
                    zoom: 15,
                    minZoom: 3,
                    maxZoom: 20,
                    onPositionChanged: (position, hasGesture) {
                      if (!hasGesture) {
                        return;
                      }
                      _onMapMoved(position);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConfig.mapTileUrlTemplate,
                      subdomains: AppConfig.mapTileSubdomains,
                      userAgentPackageName: 'com.cycloroute.mobile',
                      maxNativeZoom: 18,
                      maxZoom: 20,
                      backgroundColor: AppColors.background,
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          AppConfig.mapAttribution,
                          textStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IgnorePointer(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 44,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.white,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        l10n.dragMapToAdjustPin,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_map_picker',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: () async {
                      final locationProvider =
                          context.read<LocationProvider>();
                      final granted = await locationProvider.ensureAccess(
                        context,
                      );
                      if (!granted || !mounted) return;
                      final location = locationProvider.currentLocation;
                      if (location == null || !mounted) return;
                      final target =
                          LatLng(location.latitude, location.longitude);
                      _mapController.move(target, 16);
                      setState(() => _selectedCenter = target);
                      _scheduleReverseGeocode(target);
                    },
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loadingAddress)
                    const LinearProgressIndicator(minHeight: 2)
                  else
                    const SizedBox(height: 2),
                  const SizedBox(height: 10),
                  Text(
                    _addressLabel ?? l10n.mapSelectedLocation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedCenter == null ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.confirmLocation,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
