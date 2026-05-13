import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/data/mock/mock_alerts.dart';
import 'package:cyclerisk/data/mock/mock_routes.dart' as routes;
import 'package:cyclerisk/features/navigation/presentation/widgets/navigation_map_widget.dart';
import 'package:cyclerisk/features/navigation/presentation/widgets/active_alert_card.dart';
import 'package:cyclerisk/features/risk_alert/presentation/widgets/risk_alert_modal.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late routes.Route activeRoute;
  late RiskAlert activeAlert;
  late List<RiskAlert> nearbyAlerts;

  @override
  void initState() {
    super.initState();
    activeRoute = routes.MockRoutes.getActiveRoute();
    activeAlert = MockAlerts.getActiveAlert();
    nearbyAlerts = MockAlerts.getNearbyAlerts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  void _showAlertModal(RiskAlert alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) => RiskAlertModal(alert: alert),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.background,
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return AppColors.safeGreen;
      case 'medium':
        return AppColors.riskYellow;
      case 'high':
        return AppColors.alertRed;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navigationTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // End ride
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('End Ride'),
                  content: const Text(
                    'Are you sure you want to end this ride? Your journey will be recorded.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      child: const Text('End Ride'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen navigation map
          Positioned.fill(
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: screenHeight,
                    child: NavigationMapWidget(
                      routeName: activeRoute.name,
                      currentLocation: locationProvider.currentLocation ??
                          LatLng(37.4219983, -122.084),
                    ),
                  ),
                );
              },
            ),
          ),

          // Route progress overlay (top) - Floating Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Route name and progress percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeRoute.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '45% of route completed',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navigationCyan,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '45%',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.45,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.navigationCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats in row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CompactStat(
                        icon: Icons.straight,
                        label: 'Distance',
                        value:
                            '${activeRoute.distance.toStringAsFixed(1)} km',
                        context: context,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.divider,
                      ),
                      _CompactStat(
                        icon: Icons.schedule,
                        label: 'Time',
                        value: '${activeRoute.duration} min',
                        context: context,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.divider,
                      ),
                      _CompactStat(
                        icon: Icons.warning_amber,
                        label: 'Risk',
                        value: activeRoute.riskLevel.toUpperCase(),
                        context: context,
                        color: _getRiskColor(activeRoute.riskLevel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Alerts and actions (bottom sheet)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
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
                      const SizedBox(height: 16),

                      // Alerts section
                      if (nearbyAlerts.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.alertsNearby,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.alertRed
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${nearbyAlerts.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.alertRed,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...nearbyAlerts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final alert = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < nearbyAlerts.length - 1
                                  ? 12
                                  : 16,
                            ),
                            child: ActiveAlertCard(
                              alert: alert,
                              onTap: () => _showAlertModal(alert),
                            ),
                          );
                        }).toList(),
                      ],

                      // Quick actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showAlertModal(activeAlert),
                              icon: const Icon(Icons.warning_amber),
                              label: const Text('View Alert'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Keep pedaling safely!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Continue'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final BuildContext context;
  final Color? color;

  const _CompactStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? AppColors.navigationCyan,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
