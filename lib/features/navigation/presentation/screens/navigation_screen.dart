import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_preview_panel.dart';
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
                      showEmbeddedOverlays: false,
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _InstructionCard(
                        key: ValueKey(
                          '${step?.instruction}-${step?.type}-${step?.name}',
                        ),
                        instruction: controller.instruction,
                        stepType: step?.type ?? 'continue',
                        streetName: step?.name,
                        distanceLabel: _distanceLabel(distanceFormat, step),
                        progressPercent: progressPercent,
                        isRerouting: controller.isRerouting,
                        bannerText: _bannerText(l10n, controller),
                        offRoute: controller.distanceToRouteM > 40,
                        offRouteLabel: l10n.offRoute,
                        l10n: l10n,
                      ),
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
                  child: _NavigationRoutePanel(
                    route: route,
                    stepSegment: step?.segment,
                    progress: controller.progress,
                    distanceFormat: distanceFormat,
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
    super.key,
    required this.instruction,
    required this.stepType,
    required this.progressPercent,
    required this.isRerouting,
    required this.offRoute,
    required this.offRouteLabel,
    required this.l10n,
    this.streetName,
    this.distanceLabel,
    this.bannerText,
  });

  final String instruction;
  final String stepType;
  final String? streetName;
  final String? distanceLabel;
  final int progressPercent;
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
        ],
      ),
    );
  }
}

class _NavigationRoutePanel extends StatefulWidget {
  const _NavigationRoutePanel({
    required this.route,
    required this.onEndRoute,
    required this.l10n,
    required this.distanceFormat,
    this.stepSegment,
    this.progress = 0,
  });

  final RouteOption route;
  final RouteStepSegment? stepSegment;
  final double progress;
  final DistanceFormat distanceFormat;
  final VoidCallback onEndRoute;
  final AppLocalizations l10n;

  @override
  State<_NavigationRoutePanel> createState() => _NavigationRoutePanelState();
}

class _NavigationRoutePanelState extends State<_NavigationRoutePanel> {
  bool _expanded = false;

  void _openFullRouteDetails() {
    final route = widget.route;
    final l10n = widget.l10n;
    final distanceFormat = widget.distanceFormat;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    route.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: RouteDetailPreviewPanel(
                        route: route,
                        l10n: l10n,
                        distanceFormat: distanceFormat,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final l10n = widget.l10n;
    final distanceFormat = widget.distanceFormat;
    final infraPercent = (route.bikeInfrastructureCoverage * 100).round();
    final durationMin = route.durationRounded;
    final remainingMin = _remainingMinutes(durationMin, widget.progress);
    final arrivalLabel = _estimatedArrivalLabel(context, l10n, remainingMin);

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
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              route.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _RouteSummaryLine(
                        durationLabel: l10n.minutesShort(remainingMin),
                        distanceLabel: distanceFormat.formatRouteDistance(
                          route.distanceM,
                        ),
                        arrivalLabel: arrivalLabel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeInCubic,
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
              sizeCurve: Curves.easeOutCubic,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.stepSegment != null)
                      CurrentSegmentPanel(
                        segment: widget.stepSegment!,
                        l10n: l10n,
                      ),
                    if (widget.stepSegment != null) const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.navigationCyan,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_bike_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.bikeInfrastructure,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          l10n.percentBikeInfra(infraPercent),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _openFullRouteDetails,
                        icon: const Icon(Icons.open_in_full_rounded, size: 18),
                        label: Text(l10n.routeDetailTitle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onEndRoute,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(l10n.endRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _remainingMinutes(int totalMinutes, double progress) {
    if (totalMinutes <= 0) {
      return 0;
    }
    final remaining =
        ((1 - progress.clamp(0.0, 1.0)) * totalMinutes).round();
    return remaining.clamp(0, totalMinutes);
  }

  String _estimatedArrivalLabel(
    BuildContext context,
    AppLocalizations l10n,
    int remainingMinutes,
  ) {
    final arrival = DateTime.now().add(Duration(minutes: remainingMinutes));
    final locale = Localizations.localeOf(context).toString();
    final timeLabel = DateFormat.jm(locale).format(arrival);
    return l10n.estimatedArrivalTime(timeLabel);
  }
}

class _RouteSummaryLine extends StatelessWidget {
  const _RouteSummaryLine({
    required this.durationLabel,
    required this.distanceLabel,
    required this.arrivalLabel,
  });

  final String durationLabel;
  final String distanceLabel;
  final String arrivalLabel;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );
    final separatorStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(durationLabel, style: valueStyle),
        Text('·', style: separatorStyle),
        Text(distanceLabel, style: valueStyle),
        Text('·', style: separatorStyle),
        Text(arrivalLabel, style: valueStyle),
      ],
    );
  }
}
