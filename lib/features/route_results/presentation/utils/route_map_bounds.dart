import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteMapBounds {
  const RouteMapBounds({required this.center, required this.zoom});

  final LatLng center;
  final double zoom;

  static RouteMapBounds fromPoints(List<GeoPoint> points) {
    if (points.isEmpty) {
      return RouteMapBounds(center: LatLng(0, 0), zoom: 13);
    }

    var minLat = points.first.lat;
    var maxLat = points.first.lat;
    var minLng = points.first.lng;
    var maxLng = points.first.lng;

    for (final point in points) {
      minLat = math.min(minLat, point.lat);
      maxLat = math.max(maxLat, point.lat);
      minLng = math.min(minLng, point.lng);
      maxLng = math.max(maxLng, point.lng);
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();
    final span = math.max(latSpan, lngSpan);

    final zoom = switch (span) {
      < 0.015 => 15.0,
      < 0.035 => 14.0,
      < 0.08 => 13.0,
      < 0.18 => 12.0,
      _ => 11.0,
    };

    return RouteMapBounds(center: center, zoom: zoom);
  }
}
