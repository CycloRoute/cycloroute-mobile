import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/navigation/presentation/utils/route_segment_polylines.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/shared/widgets/osm_map_widget.dart';

class NavigationMapWidget extends StatelessWidget {
  final String routeName;
  final LatLng? currentLocation;
  final List<LatLng> routePoints;
  final RouteOption? route;
  final double? bikeInfrastructureCoverage;
  final double? deviceHeading;
  final double? targetBearing;
  final double relativeTurn;
  final String navigationInstruction;
  final double progress;
  final bool rotateMapWithHeading;
  final double height;
  final double borderRadius;

  const NavigationMapWidget({
    Key? key,
    this.routeName = 'Active Route',
    this.currentLocation,
    this.routePoints = const [],
    this.route,
    this.bikeInfrastructureCoverage,
    this.deviceHeading,
    this.targetBearing,
    this.relativeTurn = 0,
    this.navigationInstruction = 'Keep straight',
    this.progress = 0,
    this.rotateMapWithHeading = true,
    this.height = 280,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final center = currentLocation ?? LatLng(37.4219983, -122.084);
    final points = routePoints.isNotEmpty
        ? routePoints
        : <LatLng>[
            center,
            LatLng(center.latitude + 0.003, center.longitude + 0.002),
            LatLng(center.latitude + 0.006, center.longitude + 0.006),
            LatLng(center.latitude + 0.008, center.longitude + 0.010),
          ];
    final destination = points.last;
    final mapRotation = rotateMapWithHeading && deviceHeading != null
        ? (360 - deviceHeading!) % 360
        : 0.0;
    final polylines = route != null
        ? RouteSegmentPolylines.forRoute(route!)
        : [
            Polyline(
              points: points,
              strokeWidth: 5,
              color: AppColors.safeGreen,
            ),
          ];

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderRadius <= 0
            ? null
            : Border.all(color: AppColors.divider, width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: OsmMapWidget(
              center: center,
              zoom: 16,
              height: height,
              rotation: mapRotation,
              borderRadius: borderRadius,
              markers: [
                Marker(
                  width: 48,
                  height: 48,
                  point: center,
                  builder: (_) => Transform.rotate(
                    angle: _degreesToRadians(
                      rotateMapWithHeading
                          ? 0
                          : (deviceHeading ?? targetBearing ?? 0),
                    ),
                    child: Container(
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
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
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
              polylines: polylines,
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
                  if (bikeInfrastructureCoverage != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.safeGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.safeGreen.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pedal_bike_rounded,
                            color: AppColors.safeGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(bikeInfrastructureCoverage! * 100).round()}%',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.safeGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: _DirectionBubble(
              relativeTurn: relativeTurn,
              instruction: navigationInstruction,
              progress: progress,
              mapLockedToHeading: rotateMapWithHeading && deviceHeading != null,
            ),
          ),
        ],
      ),
    );
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}

class _DirectionBubble extends StatelessWidget {
  const _DirectionBubble({
    required this.relativeTurn,
    required this.instruction,
    required this.progress,
    required this.mapLockedToHeading,
  });

  final double relativeTurn;
  final String instruction;
  final double progress;
  final bool mapLockedToHeading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: relativeTurn * math.pi / 180,
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mapLockedToHeading ? instruction : '$instruction to route',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
