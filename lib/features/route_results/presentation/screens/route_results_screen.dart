import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/data/mock/mock_routes.dart' as route_data;
import 'package:cyclerisk/features/route_results/presentation/widgets/route_option_card.dart';

class RouteResultsScreen extends StatefulWidget {
  const RouteResultsScreen({super.key});

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  late final List<route_data.Route> routes;
  late route_data.Route selectedRoute;
  String? destination;

  @override
  void initState() {
    super.initState();
    routes = route_data.MockRoutes.getSampleRoutes();
    selectedRoute = routes.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    destination ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Route options'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination == null
                    ? 'Choose your route'
                    : 'Routes to $destination',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.05,
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 6),
              Text(
                'Pick the route that feels right: faster, calmer, or more protected.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 320.ms),
              const SizedBox(height: 18),
              Text(
                    'Route options',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 360.ms)
                  .slideX(begin: -0.03, end: 0),
              const SizedBox(height: 6),
              Text(
                'Tap a route to paint its path and details.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 160.ms, duration: 320.ms),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.74),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: routes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final route = entry.value;

                      return Column(
                        children: [
                          RouteOptionCard(
                                route: route,
                                isSelected: selectedRoute.id == route.id,
                                onSelect: () =>
                                    setState(() => selectedRoute = route),
                              )
                              .animate()
                              .fadeIn(delay: (70 * index).ms, duration: 320.ms)
                              .slideX(begin: 0.03, end: 0),
                          if (index < routes.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.divider.withOpacity(0.7),
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
                  color: Colors.white.withOpacity(0.76),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selected route',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${selectedRoute.distance.toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 360.ms),
                    const SizedBox(height: 12),
                    Text(
                      selectedRoute.waypoints.join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/navigation',
                          arguments: {
                            'route': selectedRoute,
                            'destination': destination,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start navigation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 220.ms, duration: 360.ms)
                  .slideY(begin: 0.08, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
