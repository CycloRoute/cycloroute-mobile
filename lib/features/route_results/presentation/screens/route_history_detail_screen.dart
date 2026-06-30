import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/utils/route_history_format.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_launch_service.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/models/route_options_result.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_info_row.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_preview_panel.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_preview_map_widget.dart';

class RouteHistoryDetailScreen extends StatefulWidget {
  const RouteHistoryDetailScreen({super.key});

  @override
  State<RouteHistoryDetailScreen> createState() =>
      _RouteHistoryDetailScreenState();
}

class _RouteHistoryDetailScreenState extends State<RouteHistoryDetailScreen> {
  final RouteApiService _routeApiService = RouteApiService();
  final NavigationLaunchService _navigationLaunchService =
      NavigationLaunchService();

  late RouteHistoryItem _item;
  bool _loadedArgs = false;
  bool _startingNavigation = false;
  bool _savingRoute = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArgs) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! RouteHistoryItem) {
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

  Future<void> _saveRoute() async {
    final l10n = appL10n(context);
    final route = _item.routePayload;
    final origin = _item.origin;
    final destination = _item.destination;

    if (route == null || origin == null || destination == null) {
      setState(() => _errorMessage = l10n.routeHistoryMissingPayload);
      return;
    }

    final token = await _accessToken();
    if (token == null) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.pleaseSignInAgain);
      return;
    }

    setState(() {
      _savingRoute = true;
      _errorMessage = null;
    });

    try {
      await _routeApiService.saveRoute(
        selectedRoute: route,
        accessToken: token,
        name: _item.displayTitle,
        meta: SavedRouteMeta(
          origin: origin,
          destination: destination,
          originLabel: _item.originLabel,
          destinationLabel: _item.destinationLabel,
          planningPreference: _item.meta?.planningPreference,
          bikeProfile: _item.meta?.bikeProfile,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routeSavedSuccessfully)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotSaveRoute);
    } finally {
      if (mounted) {
        setState(() => _savingRoute = false);
      }
    }
  }

  Future<void> _startNavigation() async {
    final l10n = appL10n(context);
    final route = _item.routePayload;
    final origin = _item.origin;
    final destination = _item.destination;

    if (route == null || origin == null || destination == null) {
      setState(() => _errorMessage = l10n.routeHistoryMissingPayload);
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
        destinationLabel: _item.destinationLabel ?? _item.displayTitle,
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
    final localeName = Localizations.localeOf(context).toString();

    if (!_loadedArgs) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.routeHistoryDetailTitle)),
        body: Center(child: Text(l10n.routeHistoryMissingPayload)),
      );
    }

    final route = _item.routePayload;
    final infraPercent =
        ((route?.bikeInfrastructureCoverage ?? 0) * 100).round();
    final cycloPercent = ((route?.cycloScore ?? 0) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeHistoryDetailTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: route == null || _item.origin == null || _item.destination == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.routeHistoryMissingPayload,
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
                    _item.displayTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (_item.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.routeHistoryCompletedAt(
                        RouteHistoryFormat.formatCompletedAt(
                          _item.createdAt!,
                          localeName,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
                    value: '$cycloPercent',
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
                      onPressed: _startingNavigation || _savingRoute
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _startingNavigation || _savingRoute
                          ? null
                          : _saveRoute,
                      icon: _savingRoute
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bookmark_add_outlined),
                      label: Text(l10n.saveRoute),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
