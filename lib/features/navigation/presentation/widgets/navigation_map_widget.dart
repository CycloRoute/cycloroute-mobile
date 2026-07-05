import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/navigation/presentation/utils/route_segment_polylines.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_marker_tap.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map.dart';
import 'package:cyclerisk/features/reports/presentation/widgets/obstacle_detail_sheet.dart';

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
  final bool showRouteObstacles;
  final bool showEmbeddedOverlays;
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
    this.showRouteObstacles = true,
    this.showEmbeddedOverlays = true,
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
            child: CycloMap(
              center: center,
              zoom: 16,
              height: height,
              rotation: mapRotation,
              borderRadius: borderRadius,
              layers: CycloMapLayers(
                showUserLocation: false,
                showRoutes: true,
                showCommunityObstacles: showRouteObstacles,
              ),
              mode: CycloMapMode.user,
              polylines: polylines,
              onMarkerTap: showRouteObstacles
                  ? (tap) {
                      if (tap case CycloMapObstacleTap(:final report)) {
                        showObstacleDetailSheet(context, report);
                      }
                    }
                  : null,
              extraMarkers: [
                Marker(
                  width: 54,
                  height: 54,
                  point: center,
                  rotate: false,
                  builder: (_) => Transform.rotate(
                    angle: _degreesToRadians(
                      rotateMapWithHeading
                          ? 0
                          : (deviceHeading ?? targetBearing ?? 0),
                    ),
                    child: const _NavigationCursor(),
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
            ),
          ),
          if (showEmbeddedOverlays)
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
          if (showEmbeddedOverlays)
            Positioned(
            right: 14,
            bottom: 14,
            child: _DirectionBubble(
              relativeTurn: relativeTurn,
              instruction: navigationInstruction,
              progress: progress,
            ),
          ),
        ],
      ),
    );
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}

/// User position puck for turn-by-turn. The chevron points "up" which, in the
/// heading-up map, always represents the rider's forward direction of travel.
class _NavigationCursor extends StatelessWidget {
  const _NavigationCursor();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(54, 54), painter: _HeadingBeamPainter()),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.navigationCyan,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment(0, -0.62),
            child: Icon(
              Icons.navigation_rounded,
              color: AppColors.navigationCyan,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a translucent cone above the puck, hinting the forward direction.
class _HeadingBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final beamPaint = Paint()
      ..shader = ui.Gradient.radial(center, size.width / 2, [
        AppColors.navigationCyan.withValues(alpha: 0.32),
        AppColors.navigationCyan.withValues(alpha: 0.0),
      ]);

    const spreadRad = 0.9;
    const startAngle = -math.pi / 2 - spreadRad / 2;
    final path = ui.Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: size.width / 2),
        startAngle,
        spreadRad,
        false,
      )
      ..close();
    canvas.drawPath(path, beamPaint);
  }

  @override
  bool shouldRepaint(covariant _HeadingBeamPainter oldDelegate) => false;
}

class _DirectionBubble extends StatelessWidget {
  const _DirectionBubble({
    required this.relativeTurn,
    required this.instruction,
    required this.progress,
  });

  final double relativeTurn;
  final String instruction;
  final double progress;

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
            instruction,
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
