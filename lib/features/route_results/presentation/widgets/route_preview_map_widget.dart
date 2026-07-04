import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_options_result.dart';
import 'package:cyclerisk/features/navigation/presentation/utils/route_segment_polylines.dart';
import 'package:cyclerisk/features/route_results/presentation/utils/route_map_bounds.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map.dart';

class RoutePreviewMapWidget extends StatelessWidget {
  const RoutePreviewMapWidget({
    super.key,
    required this.result,
    required this.selectedRoute,
    this.height = 240,
    this.expand = false,
  });

  final RouteOptionsResult result;
  final RouteOption selectedRoute;
  final double height;
  final bool expand;

  Color _routeColor(String routeId, {required bool selected}) {
    final color = switch (routeId.toLowerCase()) {
      'recommended' => AppColors.primary,
      'balanced' => AppColors.navigationCyan,
      'shorter' => const Color(0xFF6366F1),
      _ => AppColors.textSecondary,
    };
    if (selected) {
      return color;
    }
    return color.withValues(alpha: 0.28);
  }

  List<Polyline> _polylinesForRoute(RouteOption route, {required bool selected}) {
    final fallbackColor = _routeColor(route.routeId, selected: selected);
    if (selected &&
        route.segments != null &&
        route.segments!.isNotEmpty) {
      return RouteSegmentPolylines.forRoute(
        route,
        strokeWidth: 5.5,
        fallbackStrokeWidth: 5.5,
        fallbackColor: fallbackColor,
        selected: true,
      );
    }

    return [
      Polyline(
        points: route.coordinates
            .map((point) => LatLng(point.lat, point.lng))
            .toList(),
        strokeWidth: selected ? 5.5 : 3,
        color: fallbackColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bounds = RouteMapBounds.fromPoints([
      result.origin,
      result.destination,
      ...selectedRoute.coordinates,
    ]);

    final polylines = <Polyline>[
      for (final route in result.routes)
        if (route.coordinates.length >= 2)
          ..._polylinesForRoute(
            route,
            selected: route.routeId == selectedRoute.routeId,
          ),
    ];

    final map = Stack(
      children: [
        expand
            ? SizedBox.expand(
                child: CycloMap(
                  center: bounds.center,
                  zoom: bounds.zoom,
                  height: double.infinity,
                  borderRadius: 0,
                  layers: CycloMapLayers.routePreview,
                  polylines: polylines,
                  extraMarkers: _markers(result),
                ),
              )
            : CycloMap(
                center: bounds.center,
                zoom: bounds.zoom,
                height: height,
                borderRadius: 0,
                layers: CycloMapLayers.routePreview,
                polylines: polylines,
                extraMarkers: _markers(result),
              ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendDot(color: _routeColor(selectedRoute.routeId, selected: true)),
                const SizedBox(width: 6),
                Text(
                  selectedRoute.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (expand) {
      return map;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: map,
      ),
    );
  }

  List<Marker> _markers(RouteOptionsResult result) {
    return [
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(result.origin.lat, result.origin.lng),
                  builder: (_) => _MapPin(
                    color: AppColors.primary,
                    icon: Icons.trip_origin_rounded,
                  ),
                ),
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(
                    result.destination.lat,
                    result.destination.lng,
                  ),
                  builder: (_) => _MapPin(
                    color: AppColors.navigationCyan,
                    icon: Icons.flag_rounded,
                  ),
                ),
              ];
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
