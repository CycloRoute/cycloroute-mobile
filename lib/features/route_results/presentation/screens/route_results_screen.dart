import 'package:flutter/material.dart';
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
import 'package:cyclerisk/features/route_results/presentation/widgets/route_option_tab_panel.dart';
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
  bool _detailsExpanded = false;
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

  void _onRouteTabTap(RouteOption route) {
    final isSameRoute = _selectedRoute?.routeId == route.routeId;

    setState(() {
      if (isSameRoute) {
        _detailsExpanded = !_detailsExpanded;
      } else {
        _selectedRoute = route;
        _detailsExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final result = _result;
    final selectedRoute = _selectedRoute;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.destinationLabel == null
                  ? l10n.routeOptionsTitle
                  : l10n.routesTo(result.destinationLabel!),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            if (result.originLabel != null)
              Text(
                l10n.startingFrom(result.originLabel!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.alertRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Expanded(
            child: RoutePreviewMapWidget(
              result: result,
              selectedRoute: selectedRoute,
              expand: true,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider.withValues(alpha: 0.9)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Row(
                      children: [
                        for (var index = 0; index < result.routes.length; index++) ...[
                          if (index > 0) const SizedBox(width: 8),
                          RouteOptionTabChip(
                            route: result.routes[index],
                            isSelected:
                                selectedRoute.routeId == result.routes[index].routeId,
                            isExpanded: _detailsExpanded &&
                                selectedRoute.routeId == result.routes[index].routeId,
                            onTap: () => _onRouteTabTap(result.routes[index]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_detailsExpanded)
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.28,
                      child: RouteOptionTabPanel(
                        key: ValueKey(selectedRoute.routeId),
                        route: selectedRoute,
                        onStartNavigation: _startNavigation,
                        startingNavigation: _startingNavigation,
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
