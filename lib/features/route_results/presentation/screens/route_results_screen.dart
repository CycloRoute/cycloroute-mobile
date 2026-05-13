import 'package:flutter/material.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/data/mock/mock_routes.dart' as route_data;
import 'package:cyclerisk/shared/widgets/primary_button.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_option_card.dart';

class RouteResultsScreen extends StatefulWidget {
  const RouteResultsScreen({Key? key}) : super(key: key);

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  late List<route_data.Route> routes;
  late route_data.Route selectedRoute;

  @override
  void initState() {
    super.initState();
    routes = route_data.MockRoutes.getSampleRoutes();
    selectedRoute = routes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.routeResultsTitle),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.safeGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.safeGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.safeGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Routes calculated!',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose the route that best fits your needs.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Route options
              Text(
                'Available routes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...routes.asMap().entries.map((entry) {
                final index = entry.key;
                final route = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < routes.length - 1 ? 12 : 0,
                  ),
                  child: RouteOptionCard(
                    route: route,
                    isSelected: selectedRoute.id == route.id,
                    onSelect: () {
                      setState(() {
                        selectedRoute = route;
                      });
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),

              // Route details
              ...[
                Text(
                  'Route Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waypoints',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...selectedRoute.waypoints.asMap().entries.map((entry) {
                        final index = entry.key;
                        final waypoint = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < selectedRoute.waypoints.length - 1
                                ? 8
                                : 0,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.navigationCyan,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  waypoint,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Start ride button
              PrimaryButton(
                label: AppStrings.startRide,
                onPressed: () {
                  Navigator.of(context).pushNamed('/navigation');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
