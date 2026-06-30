import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/services/user_preferences_sync.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/navigation/presentation/navigation_resume_coordinator.dart';
import 'package:cyclerisk/features/navigation/presentation/widgets/active_navigation_banner.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:cyclerisk/features/shared/widgets/location_permission_banner.dart';
import 'package:cyclerisk/features/shared/widgets/osm_map_widget.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.refreshAccessStatus();
      if (locationProvider.hasLocationAccess) {
        await locationProvider.getCurrentLocation();
      }
      if (!mounted) return;
      final user = await context.read<AuthProvider>().refreshProfile();
      if (!mounted) return;
      await UserPreferencesSync.applyFromAuthUserIfPresent(
        user: user,
        bikeProfileProvider: context.read<BikeProfileProvider>(),
        navigationPreferencesProvider:
            context.read<NavigationPreferencesProvider>(),
      );
      if (!mounted) return;
      await NavigationResumeCoordinator.presentIfNeeded(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) {
      return;
    }

    final locationProvider = context.read<LocationProvider>();
    locationProvider.refreshAccessStatus().then((_) async {
      if (!mounted) return;
      if (locationProvider.hasLocationAccess) {
        await locationProvider.getCurrentLocation();
      }
    });
  }

  void _openRouteSearch() {
    Navigator.of(context).pushNamed(AppRoutes.routeSearch);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _HomeMenuButton(l10n: l10n),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<LocationProvider>(
              builder: (context, loc, _) {
                final location = loc.currentLocation;
                return OsmMapWidget(
                  center: location,
                  zoom: location == null ? 13 : 17,
                  markers: location == null
                      ? const []
                      : [
                          Marker(
                            width: 46,
                            height: 46,
                            point: location,
                            builder: (_) => Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.primaryGradient,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
            left: 16,
            right: 16,
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LocationPermissionBanner(),
                    const SizedBox(height: 10),
                    const ActiveNavigationBanner(),
                    const SizedBox(height: 10),
                    _WelcomeCard(name: auth.firstName),
                    const SizedBox(height: 12),
                    _SearchDestinationCard(onTap: _openRouteSearch),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _HomeBottomPanel(
              l10n: l10n,
              onOpenSaved: () =>
                  Navigator.of(context).pushNamed(AppRoutes.savedRoutes),
              onOpenHistory: () =>
                  Navigator.of(context).pushNamed(AppRoutes.routeHistory),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.pedal_bike_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeUser(name),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.readyForRouteSearchSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.05, end: 0);
  }
}

class _SearchDestinationCard extends StatelessWidget {
  const _SearchDestinationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066CC), Color(0xFF0E8EC8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.search_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.whereTo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.searchDestinationHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 320.ms).slideY(begin: 0.06, end: 0);
  }
}

class _HomeBottomPanel extends StatelessWidget {
  const _HomeBottomPanel({
    required this.l10n,
    required this.onOpenSaved,
    required this.onOpenHistory,
  });

  final AppLocalizations l10n;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeQuickAccess,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.bookmark_outline_rounded,
                  label: l10n.savedRoutes,
                  color: AppColors.primary,
                  onTap: onOpenSaved,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.history_rounded,
                  label: l10n.routeHistory,
                  color: AppColors.navigationCyan,
                  onTap: onOpenHistory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(14),
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuSelection(context, value),
        itemBuilder: (BuildContext context) {
          final auth = context.read<AuthProvider>();
          return <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.profile),
              ),
            ),
            PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.settings),
              ),
            ),
            PopupMenuItem<String>(
              value: 'saved_routes',
              child: ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: Text(l10n.savedRoutes),
              ),
            ),
            PopupMenuItem<String>(
              value: 'route_history',
              child: ListTile(
                leading: const Icon(Icons.history_rounded),
                title: Text(l10n.routeHistory),
              ),
            ),
            PopupMenuItem<String>(
              value: 'create_report',
              child: ListTile(
                leading: const Icon(Icons.report_outlined),
                title: Text(l10n.reportObstacle),
              ),
            ),
            PopupMenuItem<String>(
              value: 'my_reports',
              child: ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: Text(l10n.myObstacleReports),
              ),
            ),
            if (auth.canReviewInfrastructure) ...[
              PopupMenuItem<String>(
                value: 'collaborative_map',
                child: ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(l10n.collaborativeMap),
                ),
              ),
              PopupMenuItem<String>(
                value: 'route_coverage',
                child: ListTile(
                  leading: const Icon(Icons.layers_outlined),
                  title: Text(l10n.aiRouteCoverage),
                ),
              ),
              PopupMenuItem<String>(
                value: 'reviewer_capture',
                child: ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(l10n.reviewInfrastructure),
                ),
              ),
              PopupMenuItem<String>(
                value: 'reports_list',
                child: ListTile(
                  leading: const Icon(Icons.list_alt_outlined),
                  title: Text(l10n.obstacleReports),
                ),
              ),
              PopupMenuItem<String>(
                value: 'reviewer_tools',
                child: ListTile(
                  leading: const Icon(Icons.build_circle_outlined),
                  title: Text(l10n.reviewerTools),
                ),
              ),
            ],
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.alertRed),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: AppColors.alertRed),
                ),
              ),
            ),
          ];
        },
        icon: const Icon(Icons.more_vert),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'logout') {
      context.read<AuthProvider>().logout();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.authEntry);
      });
      return;
    }

    final routes = <String, String>{
      'profile': AppRoutes.profile,
      'settings': AppRoutes.settings,
      'saved_routes': AppRoutes.savedRoutes,
      'route_history': AppRoutes.routeHistory,
      'create_report': AppRoutes.createReport,
      'my_reports': AppRoutes.myReports,
      'collaborative_map': AppRoutes.collaborativeMap,
      'route_coverage': AppRoutes.routeCoverage,
      'reviewer_capture': AppRoutes.reviewerCapture,
      'reports_list': AppRoutes.reportsList,
      'reviewer_tools': AppRoutes.reviewerTools,
    };

    final route = routes[value];
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }
}
