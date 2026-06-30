import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_launch_service.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/models/route_options_result.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_info_row.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_preview_panel.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_preview_map_widget.dart';

class SavedRouteDetailScreen extends StatefulWidget {
  const SavedRouteDetailScreen({super.key});

  @override
  State<SavedRouteDetailScreen> createState() => _SavedRouteDetailScreenState();
}

class _SavedRouteDetailScreenState extends State<SavedRouteDetailScreen> {
  final RouteApiService _routeApiService = RouteApiService();
  final NavigationLaunchService _navigationLaunchService =
      NavigationLaunchService();

  late SavedRouteItem _item;
  bool _loadedArgs = false;
  bool _startingNavigation = false;
  bool _deleting = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArgs) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! SavedRouteItem) {
      return;
    }

    _item = args;
    _loadedArgs = true;
  }

  Future<String?> _accessToken() async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  Future<void> _renameRoute() async {
    final l10n = appL10n(context);
    final controller = TextEditingController(text: _item.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameSavedRoute),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.renameSavedRouteHint,
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == _item.name) {
      return;
    }

    final token = await _accessToken();
    if (token == null) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.pleaseSignInAgain);
      return;
    }

    try {
      final updated = await _routeApiService.updateSavedRoute(
        accessToken: token,
        id: _item.id,
        name: newName,
      );
      if (!mounted) return;
      setState(() {
        _item = updated;
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRouteRenamed)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotRenameSavedRoute);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = appL10n(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSavedRoute),
        content: Text(l10n.deleteSavedRouteConfirm(_item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            child: Text(l10n.deleteSavedRoute),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    final token = await _accessToken();
    if (token == null) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.pleaseSignInAgain);
      return;
    }

    setState(() {
      _deleting = true;
      _errorMessage = null;
    });

    try {
      await _routeApiService.deleteSavedRoute(
        accessToken: token,
        id: _item.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRouteDeleted)),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotDeleteSavedRoute);
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _startNavigation() async {
    final l10n = appL10n(context);
    final route = _item.routePayload;
    final origin = _item.origin;
    final destination = _item.destination;

    if (route == null || origin == null || destination == null) {
      setState(() => _errorMessage = l10n.savedRouteMissingPayload);
      return;
    }

    setState(() {
      _startingNavigation = true;
      _errorMessage = null;
    });

    try {
      await _navigationLaunchService.launch(
        context: context,
        route: route,
        destination: destination,
        origin: origin,
        destinationLabel: _item.destinationLabel ?? _item.name,
        preference: _item.meta?.planningPreference,
        bikeProfile: _item.meta?.bikeProfile,
      );
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = NavigationLaunchService.errorMessage(l10n, error),
      );
    } finally {
      if (mounted) {
        setState(() => _startingNavigation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final distanceFormat = distanceFormatOf(context);

    if (!_loadedArgs) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.savedRouteDetailTitle)),
        body: Center(child: Text(l10n.savedRouteMissingPayload)),
      );
    }

    final route = _item.routePayload;
    final infraPercent = ((route?.bikeInfrastructureCoverage ?? 0) * 100)
        .round();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedRouteDetailTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: l10n.renameSavedRoute,
            onPressed: _deleting ? null : _renameRoute,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.deleteSavedRoute,
            onPressed: _deleting ? null : _confirmDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: route == null || _item.origin == null || _item.destination == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.savedRouteMissingPayload,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_item.originLabel != null ||
                      _item.destinationLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (_item.originLabel != null) _item.originLabel!,
                        if (_item.destinationLabel != null)
                          _item.destinationLabel!,
                      ].join(' → '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  RoutePreviewMapWidget(
                    result: RouteOptionsResult(
                      origin: _item.origin!,
                      destination: _item.destination!,
                      routes: [route],
                      originLabel: _item.originLabel,
                      destinationLabel: _item.destinationLabel,
                      planningPreference: _item.meta?.planningPreference,
                      bikeProfile: _item.meta?.bikeProfile,
                    ),
                    selectedRoute: route,
                    height: 220,
                  ),
                  const SizedBox(height: 16),
                  RouteDetailInfoRow(
                    label: l10n.distance,
                    value: distanceFormat.formatRouteDistance(route.distanceM),
                  ),
                  const SizedBox(height: 8),
                  RouteDetailInfoRow(
                    label: l10n.time,
                    value: l10n.minutesShort(route.durationRounded),
                  ),
                  const SizedBox(height: 8),
                  RouteDetailInfoRow(
                    label: l10n.bikeInfrastructure,
                    value: l10n.percentBikeInfra(infraPercent),
                  ),
                  const SizedBox(height: 8),
                  RouteDetailInfoRow(
                    label: l10n.cycloScoreLabel,
                    value: '${((route.cycloScore) * 100).round()}',
                  ),
                  if (route.why.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.selectedRouteSummary,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route.why.join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  RouteDetailPreviewPanel(
                    route: route,
                    l10n: l10n,
                    distanceFormat: distanceFormat,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
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
                      onPressed: _startingNavigation || _deleting
                          ? null
                          : _startNavigation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _startingNavigation
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.startNavigation,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
