import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/utils/route_preference_matcher.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_launch_service.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_options_result.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_info_row.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_option_card.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_preview_map_widget.dart';

class RouteResultsScreen extends StatefulWidget {
  const RouteResultsScreen({super.key});

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  final RouteApiService _routeApiService = RouteApiService();
  final NavigationLaunchService _navigationLaunchService =
      NavigationLaunchService();

  RouteOptionsResult? _result;
  RouteOption? _selectedRoute;
  bool _loadedArguments = false;
  bool _savingRoute = false;
  bool _startingNavigation = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArguments) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is RouteOptionsResult) {
      _result = arguments;
      final preference =
          arguments.planningPreference ??
          context.read<AuthProvider>().defaultRoutePreference;
      _selectedRoute = pickRouteForPreference(arguments.routes, preference);
    }

    _loadedArguments = true;
  }

  Future<void> _saveSelectedRoute() async {
    final l10n = appL10n(context);
    final result = _result;
    final selectedRoute = _selectedRoute;
    final accessToken = context.read<AuthProvider>().accessToken;

    if (result == null || selectedRoute == null) {
      return;
    }
    if (accessToken == null || accessToken.isEmpty) {
      setState(
        () => _errorMessage = l10n.pleaseSignInAgainToSaveRoute,
      );
      return;
    }

    setState(() {
      _savingRoute = true;
      _errorMessage = null;
    });

    try {
      await _routeApiService.saveRoute(
        selectedRoute: selectedRoute,
        accessToken: accessToken,
        name: 'Ruta a ${result.destinationLabel ?? 'destino'}',
        meta: SavedRouteMeta(
          origin: result.origin,
          destination: result.destination,
          originLabel: result.originLabel,
          destinationLabel: result.destinationLabel,
          planningPreference: result.planningPreference,
          bikeProfile: result.bikeProfile,
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
    final result = _result;
    final selectedRoute = _selectedRoute;
    final accessToken = context.read<AuthProvider>().accessToken;

    if (result == null || selectedRoute == null) {
      return;
    }
    if (accessToken == null || accessToken.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseSignInToCalculateRoutes);
      return;
    }

    setState(() {
      _startingNavigation = true;
      _errorMessage = null;
    });

    try {
      await _navigationLaunchService.launch(
        context: context,
        route: selectedRoute,
        destination: result.destination,
        origin: result.origin,
        originLabel: result.originLabel,
        destinationLabel: result.destinationLabel,
        preference: result.planningPreference ??
            RoutePreference.fromApi(selectedRoute.routeId),
        bikeProfile: result.bikeProfile,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage = NavigationLaunchService.errorMessage(l10n, error),
      );
    } finally {
      if (mounted) {
        setState(() => _startingNavigation = false);
      }
    }
  }

  void _selectRoute(RouteOption route) {
    setState(() => _selectedRoute = route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final distanceFormat = distanceFormatOf(context);
    final result = _result;
    final selectedRoute = _selectedRoute;
    final cycloPercent = ((selectedRoute?.cycloScore ?? 0) * 100).round();

    if (result == null || selectedRoute == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.routeOptionsTitle),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Center(child: Text(l10n.noRouteOptionsLoaded)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.routeOptionsTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.saveRoute,
            onPressed: _savingRoute ? null : _saveSelectedRoute,
            icon: _savingRoute
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.destinationLabel == null
                    ? l10n.chooseYourRoute
                    : l10n.routesTo(result.destinationLabel!),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.05,
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 6),
              Text(
                result.originLabel == null
                    ? l10n.pickRouteThatFits
                    : l10n.startingFrom(result.originLabel!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 320.ms),
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
              const SizedBox(height: 16),
              RoutePreviewMapWidget(
                result: result,
                selectedRoute: selectedRoute,
              ).animate().fadeIn(delay: 120.ms, duration: 360.ms),
              const SizedBox(height: 18),
              Text(
                l10n.routeOptionsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.reviewRouteOnMap,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: result.routes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final route = entry.value;

                      return Column(
                        children: [
                          RouteOptionCard(
                            route: route,
                            isSelected:
                                selectedRoute.routeId == route.routeId,
                            onSelect: () => _selectRoute(route),
                          ).animate().fadeIn(
                            delay: (70 * index).ms,
                            duration: 320.ms,
                          ).slideX(begin: 0.03, end: 0),
                          if (index < result.routes.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.divider.withValues(alpha: 0.7),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.selectedRouteSummary,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.percentBikeInfra(
                            (selectedRoute.bikeInfrastructureCoverage * 100)
                                .round(),
                          ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${distanceFormat.formatRouteDistance(selectedRoute.distanceM)} · '
                      '${l10n.minutesShort(selectedRoute.durationRounded)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RouteDetailInfoRow(
                      label: l10n.cycloScoreLabel,
                      value: '$cycloPercent',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedRoute.why.isEmpty
                          ? l10n.percentBikeInfra(
                              (selectedRoute.bikeInfrastructureCoverage * 100)
                                  .round(),
                            )
                          : selectedRoute.why.join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 360.ms),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _startingNavigation ? null : _startNavigation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 220.ms, duration: 360.ms).slideY(
                begin: 0.08,
                end: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
