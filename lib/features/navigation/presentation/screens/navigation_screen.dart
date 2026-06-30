import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/models/navigation_location_access.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_session_controller.dart';
import 'package:cyclerisk/features/navigation/presentation/widgets/background_location_warning_banner.dart';
import 'package:cyclerisk/core/providers/compass_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/utils/distance_format.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_launch_args.dart';
import 'package:cyclerisk/features/navigation/data/models/route_step.dart';
import 'package:cyclerisk/features/navigation/data/models/route_step_segment.dart';
import 'package:cyclerisk/features/navigation/presentation/maneuver_icons.dart';
import 'package:cyclerisk/features/navigation/presentation/widgets/active_alert_card.dart';
import 'package:cyclerisk/features/navigation/presentation/widgets/current_segment_panel.dart';
import 'package:cyclerisk/features/navigation/presentation/widgets/navigation_map_widget.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _initialized = false;
  bool _starting = false;
  bool _arrivalHandled = false;
  String? _initErrorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CompassProvider>().start();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! NavigationLaunchArgs) {
      _initErrorKey = 'missing_args';
      return;
    }

    final accessToken = context.read<AuthProvider>().accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _initErrorKey = 'auth';
      return;
    }

    _starting = true;
    _bootstrapNavigation(arguments, accessToken);
  }

  Future<void> _bootstrapNavigation(
    NavigationLaunchArgs arguments,
    String accessToken,
  ) async {
    final l10n = appL10n(context);
    final locationProvider = context.read<LocationProvider>();
    final access = await locationProvider.ensureNavigationAccess(
      context,
      allowForegroundOnly: true,
    );

    if (!mounted) {
      return;
    }

    if (!access.isUsable) {
      setState(() {
        _starting = false;
        _initErrorKey = 'location';
      });
      return;
    }

    final locale = Localizations.localeOf(context);
    final navPrefs = context.read<NavigationPreferencesProvider>();
    final distanceFormat = DistanceFormat(
      unit: navPrefs.distanceUnit,
      l10n: l10n,
    );
    final controller = context.read<NavigationSessionController>();

    if (controller.isSessionActive &&
        controller.session?.id == arguments.session.id) {
      if (!mounted) {
        return;
      }
      setState(() => _starting = false);
      return;
    }

    await controller.begin(
      args: arguments,
      accessToken: accessToken,
      ttsLanguageCode: navPrefs.resolveTtsLanguageCode(locale.languageCode),
      voiceGuidanceEnabled: navPrefs.voiceGuidanceEnabled,
      arrivalTtsMessage: l10n.arrivedTitle,
      navigationActiveLabel: l10n.navigationNotificationActive,
      recalculatingNotificationLabel: l10n.recalculatingRoute,
      riskAlertTtsPrefix: l10n.riskAlertTtsPrefix,
      ttsDistanceFormatter: distanceFormat.ttsApproachDistance,
      alertDistanceFormatter: distanceFormat.ttsApproachDistance,
    );

    if (!mounted) {
      return;
    }
    setState(() => _starting = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleArrival() async {
    if (_arrivalHandled || !mounted) {
      return;
    }
    _arrivalHandled = true;

    final l10n = appL10n(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.arrivedTitle),
        content: Text(l10n.arrivedMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    _goHome();
  }

  Future<void> _confirmEndRoute() async {
    final l10n = appL10n(context);
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.endRouteTitle),
        content: Text(l10n.endRouteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.endRoute),
          ),
        ],
      ),
    );

    if (shouldEnd != true || !mounted) {
      return;
    }

    await context.read<NavigationSessionController>().cancelNavigation();
    if (!mounted) {
      return;
    }
    _goHome();
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  String _bannerText(
    AppLocalizations l10n,
    NavigationSessionController controller,
  ) {
    return switch (controller.bannerMessage) {
      'recalculating' => l10n.recalculatingRoute,
      'route_updated' => l10n.routeUpdated,
      _ => controller.bannerMessage ?? '',
    };
  }

  String _distanceLabel(
    DistanceFormat distanceFormat,
    RouteStep? step,
  ) {
    if (step == null) {
      return '';
    }
    return distanceFormat.formatStepDistance(step.distanceM.round());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final distanceFormat = distanceFormatOf(context);

    if (_initErrorKey != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navigationTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  switch (_initErrorKey) {
                    'auth' => l10n.pleaseSignInToCalculateRoutes,
                    'location' => l10n.locationRequiredForNavigation,
                    _ => l10n.navigationSessionMissing,
                  },
                  textAlign: TextAlign.center,
                ),
                if (_initErrorKey == 'location') ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final granted = await context
                          .read<LocationProvider>()
                          .ensureNavigationAccess(context);
                      if (!mounted || !granted.isUsable) return;
                      setState(() {
                        _initErrorKey = null;
                        _starting = true;
                      });
                      final args = ModalRoute.of(context)?.settings.arguments;
                      final token = context.read<AuthProvider>().accessToken;
                      if (args is NavigationLaunchArgs &&
                          token != null &&
                          token.isNotEmpty) {
                        await _bootstrapNavigation(args, token);
                      }
                    },
                    child: Text(l10n.enableLocation),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (_starting) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navigationTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final controller = context.watch<NavigationSessionController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.hasArrived) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleArrival();
          });
        }

        final route = controller.activeRoute;
        final step = controller.currentStep;
        final routePoints = controller.routeCoordinates
            .map((point) => LatLng(point.lat, point.lng))
            .toList();
        final marker = controller.markerPosition ??
            (routePoints.isNotEmpty ? routePoints.first : null);
        final compassHeading = context.watch<CompassProvider>().heading;
        final deviceHeading = compassHeading ?? controller.deviceHeading;
        final progressPercent = (controller.progress * 100).round();
        final destinationLabel = controller.destinationLabel;
        final title = destinationLabel == null
            ? l10n.navigationTitle
            : l10n.navigatingTo(destinationLabel);

        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(title),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _confirmEndRoute,
                ),
              ],
            ),
            body: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return NavigationMapWidget(
                      routeName: route?.name ?? l10n.navigationTitle,
                      currentLocation: marker,
                      routePoints: routePoints,
                      route: route,
                      bikeInfrastructureCoverage:
                          route?.bikeInfrastructureCoverage,
                      deviceHeading: deviceHeading,
                      navigationInstruction: controller.instruction,
                      progress: controller.progress,
                      height: constraints.maxHeight,
                      borderRadius: 0,
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BackgroundLocationWarningBanner(),
                    const SizedBox(height: 8),
                    _InstructionCard(
                  instruction: controller.instruction,
                  stepType: step?.type ?? 'continue',
                  streetName: step?.name,
                  distanceLabel: _distanceLabel(distanceFormat, step),
                  stepSegment: step?.segment,
                  progress: controller.progress,
                  progressPercent: progressPercent,
                  routeDistanceLabel: distanceFormat.formatRouteDistance(
                    route?.distanceM ?? 0,
                  ),
                  durationMin: route?.durationRounded ?? 0,
                  bikeInfraPercent:
                      ((route?.bikeInfrastructureCoverage ?? 0) * 100).round(),
                  isRerouting: controller.isRerouting,
                  bannerText: _bannerText(l10n, controller),
                  offRoute: controller.distanceToRouteM > 40,
                  offRouteLabel: l10n.offRoute,
                  l10n: l10n,
                    ),
                  ],
                ),
              ),
              if (controller.activeNearbyAlert != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: route != null ? 132 : 24,
                  child: ActiveAlertCard(
                    alert: controller.activeNearbyAlert!,
                    dismissLabel: l10n.dismissAlert,
                    onDismiss: () => controller.dismissActiveAlert(
                      controller.activeNearbyAlert!.id,
                    ),
                  ),
                ),
              if (!controller.hasArrived && !controller.isRerouting)
                Positioned(
                  right: 16,
                  bottom: route != null ? 148 : 88,
                  child: FloatingActionButton.small(
                    heroTag: 'report_obstacle_nav',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.alertRed,
                    onPressed: () {
                      final point = controller.markerPosition;
                      Navigator.of(context).pushNamed(
                        AppRoutes.createReport,
                        arguments: point,
                      );
                    },
                    child: const Icon(Icons.add_location_alt_outlined),
                  ),
                ),
              if (route != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _RouteBottomSheet(
                    route: route,
                    onEndRoute: _confirmEndRoute,
                    l10n: l10n,
                  ),
                ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.instruction,
    required this.stepType,
    required this.progress,
    required this.progressPercent,
    required this.routeDistanceLabel,
    required this.durationMin,
    required this.bikeInfraPercent,
    required this.isRerouting,
    required this.offRoute,
    required this.offRouteLabel,
    required this.l10n,
    this.streetName,
    this.distanceLabel,
    this.stepSegment,
    this.bannerText,
  });

  final String instruction;
  final String stepType;
  final String? streetName;
  final String? distanceLabel;
  final RouteStepSegment? stepSegment;
  final double progress;
  final int progressPercent;
  final String routeDistanceLabel;
  final int durationMin;
  final int bikeInfraPercent;
  final bool isRerouting;
  final bool offRoute;
  final String offRouteLabel;
  final String? bannerText;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRerouting || (bannerText != null && bannerText!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (isRerouting)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (isRerouting) const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isRerouting ? l10n.recalculatingRoute : bannerText!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.navigationCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  maneuverIconForType(stepType),
                  color: AppColors.navigationCyan,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instruction,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (distanceLabel != null && distanceLabel!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        distanceLabel!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (streetName != null && streetName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        streetName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (offRoute) ...[
                      const SizedBox(height: 6),
                      Text(
                        offRouteLabel,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.alertRed,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navigationCyan,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$progressPercent%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (stepSegment != null) ...[
            const SizedBox(height: 12),
            CurrentSegmentPanel(segment: stepSegment!, l10n: l10n),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.navigationCyan,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CompactStat(
                icon: Icons.straighten,
                label: l10n.distance,
                value: routeDistanceLabel,
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _CompactStat(
                icon: Icons.schedule,
                label: l10n.time,
                value: l10n.minutesShort(durationMin),
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _CompactStat(
                icon: Icons.directions_bike_rounded,
                label: l10n.bikeInfrastructure,
                value: l10n.percentBikeInfra(bikeInfraPercent),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteBottomSheet extends StatelessWidget {
  const _RouteBottomSheet({
    required this.route,
    required this.onEndRoute,
    required this.l10n,
  });

  final RouteOption route;
  final VoidCallback onEndRoute;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final infraPercent = (route.bikeInfrastructureCoverage * 100).round();
    final hasSteps = route.steps.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  l10n.percentBikeInfra(infraPercent),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (!hasSteps) ...[
              const SizedBox(height: 8),
              Text(
                l10n.noTurnByTurnSteps,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEndRoute,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(l10n.endRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.navigationCyan),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
