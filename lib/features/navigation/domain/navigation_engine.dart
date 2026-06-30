import 'dart:math' as math;

import 'package:cyclerisk/features/navigation/data/models/route_step.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class NavigationEngine {
  static const offRouteThresholdM = 40.0;
  static const rerouteCooldown = Duration(seconds: 8);
  static const offRouteStreakRequired = 2;
  static const offRouteConfirmationDuration = Duration(seconds: 3);
  static const arrivalThresholdM = 30.0;
  static const stepReachedThresholdM = 25.0;

  static double minDistanceToPolyline(GeoPoint point, List<GeoPoint> polyline) {
    if (polyline.isEmpty) {
      return double.infinity;
    }
    if (polyline.length == 1) {
      return _distanceMeters(point, polyline.first);
    }

    var best = double.infinity;
    for (var index = 0; index < polyline.length - 1; index++) {
      final distance = _distancePointToSegment(
        point,
        polyline[index],
        polyline[index + 1],
      );
      if (distance < best) {
        best = distance;
      }
    }
    return best;
  }

  static bool isOffRoute(
    GeoPoint snapped, {
    required List<GeoPoint> polyline,
    double thresholdM = offRouteThresholdM,
  }) {
    return minDistanceToPolyline(snapped, polyline) > thresholdM;
  }

  static bool canReroute({
    required DateTime? lastRerouteAt,
    Duration cooldown = rerouteCooldown,
  }) {
    if (lastRerouteAt == null) {
      return true;
    }
    return DateTime.now().difference(lastRerouteAt) > cooldown;
  }

  static bool shouldTriggerReroute({
    required int offRouteStreak,
    required DateTime? offRouteSince,
    required DateTime? lastRerouteAt,
  }) {
    if (!canReroute(lastRerouteAt: lastRerouteAt)) {
      return false;
    }
    if (offRouteStreak >= offRouteStreakRequired) {
      return true;
    }
    if (offRouteSince == null) {
      return false;
    }
    return DateTime.now().difference(offRouteSince) >=
        offRouteConfirmationDuration;
  }

  static int findCurrentStepIndex(GeoPoint position, List<RouteStep> steps) {
    if (steps.isEmpty) {
      return 0;
    }

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var index = 0; index < steps.length; index++) {
      final distance = _distanceMeters(position, steps[index].location);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = index;
      }
    }

    // Advance if we've passed the maneuver point.
    if (bestIndex < steps.length - 1) {
      final nextDistance = _distanceMeters(
        position,
        steps[bestIndex + 1].location,
      );
      if (nextDistance < bestDistance) {
        return bestIndex + 1;
      }
    }

    return bestIndex;
  }

  static double distanceAlongRouteM(
    GeoPoint position,
    List<GeoPoint> polyline,
  ) {
    if (polyline.length < 2) {
      return 0;
    }

    var bestDistance = double.infinity;
    var bestAlong = 0.0;
    var accumulated = 0.0;

    for (var index = 0; index < polyline.length - 1; index++) {
      final start = polyline[index];
      final end = polyline[index + 1];
      final segmentLength = _distanceMeters(start, end);
      final projection = _projectOnSegment(position, start, end);

      if (projection.distanceToSegment < bestDistance) {
        bestDistance = projection.distanceToSegment;
        bestAlong = accumulated + segmentLength * projection.t;
      }
      accumulated += segmentLength;
    }

    return bestAlong;
  }

  static double routeLengthM(List<GeoPoint> polyline) {
    if (polyline.length < 2) {
      return 0;
    }
    var total = 0.0;
    for (var index = 0; index < polyline.length - 1; index++) {
      total += _distanceMeters(polyline[index], polyline[index + 1]);
    }
    return total;
  }

  static double progressOnRoute(GeoPoint position, List<GeoPoint> polyline) {
    final total = routeLengthM(polyline);
    if (total <= 0) {
      return 0;
    }
    return (distanceAlongRouteM(position, polyline) / total).clamp(0.0, 1.0);
  }

  static double distanceMeters(GeoPoint a, GeoPoint b) => _distanceMeters(a, b);

  static double _distanceMeters(GeoPoint a, GeoPoint b) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(b.lat - a.lat);
    final dLng = _toRadians(b.lng - a.lng);
    final lat1 = _toRadians(a.lat);
    final lat2 = _toRadians(b.lat);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  static double _distancePointToSegment(
    GeoPoint point,
    GeoPoint start,
    GeoPoint end,
  ) {
    return _projectOnSegment(point, start, end).distanceToSegment;
  }

  static _Projection _projectOnSegment(
    GeoPoint point,
    GeoPoint start,
    GeoPoint end,
  ) {
    final originLat = _toRadians(point.lat);
    final px =
        _toRadians(point.lng - start.lng) *
        math.cos(originLat) *
        6371000;
    final py = _toRadians(point.lat - start.lat) * 6371000;
    final vx =
        _toRadians(end.lng - start.lng) * math.cos(originLat) * 6371000;
    final vy = _toRadians(end.lat - start.lat) * 6371000;
    final lengthSquared = vx * vx + vy * vy;
    final t = lengthSquared == 0
        ? 0.0
        : ((px * vx + py * vy) / lengthSquared).clamp(0.0, 1.0);
    final dx = px - vx * t;
    final dy = py - vy * t;
    return _Projection(t: t, distanceToSegment: math.sqrt(dx * dx + dy * dy));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

class _Projection {
  const _Projection({required this.t, required this.distanceToSegment});

  final double t;
  final double distanceToSegment;
}
