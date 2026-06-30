import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/utils/route_segment_colors.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_segment.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteSegmentPolylines {
  const RouteSegmentPolylines._();

  static List<Polyline> build({
    required List<GeoPoint> coordinates,
    required List<RouteSegment> segments,
    double strokeWidth = 5,
    double fallbackStrokeWidth = 5,
    Color fallbackColor = AppColors.safeGreen,
  }) {
    if (coordinates.length < 2) {
      return const [];
    }

    if (segments.isEmpty) {
      return [
        Polyline(
          points: coordinates.map((p) => LatLng(p.lat, p.lng)).toList(),
          strokeWidth: fallbackStrokeWidth,
          color: fallbackColor,
        ),
      ];
    }

    return [
      for (final segment in segments)
        if (_segmentPoints(coordinates, segment).length >= 2)
          Polyline(
            points: _segmentPoints(coordinates, segment),
            strokeWidth: strokeWidth,
            color: RouteSegmentColors.forSegment(
              condition: segment.condition,
              riskLevel: segment.riskLevel,
            ),
          ),
    ];
  }

  static List<Polyline> forRoute(
    RouteOption route, {
    double strokeWidth = 5,
    double fallbackStrokeWidth = 5,
    Color fallbackColor = AppColors.safeGreen,
    bool selected = true,
  }) {
    final segments = route.segments;
    if (segments == null || segments.isEmpty) {
      if (route.coordinates.length < 2) {
        return const [];
      }
      return [
        Polyline(
          points: route.coordinates
              .map((point) => LatLng(point.lat, point.lng))
              .toList(),
          strokeWidth: selected ? fallbackStrokeWidth : 3,
          color: selected ? fallbackColor : fallbackColor.withValues(alpha: 0.28),
        ),
      ];
    }

    return build(
      coordinates: route.coordinates,
      segments: segments,
      strokeWidth: selected ? strokeWidth : 3,
      fallbackStrokeWidth: fallbackStrokeWidth,
      fallbackColor: fallbackColor,
    );
  }

  static List<LatLng> _segmentPoints(
    List<GeoPoint> coordinates,
    RouteSegment segment,
  ) {
    if (coordinates.isEmpty) {
      return const [];
    }

    final maxIndex = coordinates.length - 1;
    final from = segment.fromIndex.clamp(0, maxIndex);
    final to = segment.toIndex.clamp(0, maxIndex);
    final start = from <= to ? from : to;
    final end = from <= to ? to : from;

    return coordinates
        .sublist(start, end + 1)
        .map((point) => LatLng(point.lat, point.lng))
        .toList();
  }
}
