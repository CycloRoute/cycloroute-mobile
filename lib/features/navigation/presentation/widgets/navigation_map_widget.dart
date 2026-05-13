import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/shared/widgets/osm_map_widget.dart';

class NavigationMapWidget extends StatelessWidget {
  final String routeName;
  final LatLng? currentLocation;

  const NavigationMapWidget({
    Key? key,
    this.routeName = 'Active Route',
    this.currentLocation,
  })
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final center = currentLocation ?? LatLng(37.4219983, -122.084);
    final destination = LatLng(
      center.latitude + 0.008,
      center.longitude + 0.010,
    );
    final routePoints = <LatLng>[
      center,
      LatLng(center.latitude + 0.003, center.longitude + 0.002),
      LatLng(center.latitude + 0.006, center.longitude + 0.006),
      destination,
    ];

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: OsmMapWidget(
              center: center,
              zoom: 14,
              markers: [
                Marker(
                  width: 48,
                  height: 48,
                  point: center,
                  builder: (_) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.navigationCyan,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_bike,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                Marker(
                  width: 42,
                  height: 42,
                  point: destination,
                  builder: (_) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.safeGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 5,
                  color: AppColors.safeGreen,
                ),
              ],
            ),
          ),
          // Route info overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.navigation,
                    color: AppColors.navigationCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routeName,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          'Actively navigating',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
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
