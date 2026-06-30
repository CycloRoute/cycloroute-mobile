import 'package:cyclerisk/features/navigation/domain/navigation_engine.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteAlertProximity {
  const RouteAlertProximity._();

  static const defaultThresholdM = 80.0;

  static double thresholdForSeverity(String severity) {
    return switch (severity.toLowerCase()) {
      'high' => 120.0,
      'medium' => 100.0,
      _ => 80.0,
    };
  }

  /// Returns the nearest non-dismissed alert relevant to the rider's position.
  ///
  /// Segment alerts use distance along the route (start of segment ± lead).
  /// API alerts without segment metadata fall back to GPS distance to the point.
  static RiskAlert? nearestForNavigation({
    required GeoPoint position,
    required List<RiskAlert> alerts,
    required Set<String> dismissedIds,
    required List<GeoPoint> routePolyline,
  }) {
    if (alerts.isEmpty) {
      return null;
    }

    final alongRouteM = routePolyline.length >= 2
        ? NavigationEngine.distanceAlongRouteM(position, routePolyline)
        : null;

    RiskAlert? nearest;
    var nearestScore = double.infinity;

    for (final alert in alerts) {
      if (dismissedIds.contains(alert.id)) {
        continue;
      }

      final leadM = thresholdForSeverity(alert.severity);
      final alongRouteScore = _alongRouteScore(
        alongRouteM: alongRouteM,
        alert: alert,
        leadM: leadM,
      );
      final gpsScore = _gpsScore(position: position, alert: alert, leadM: leadM);
      final score = alongRouteScore ?? gpsScore;
      if (score == null || score >= nearestScore) {
        continue;
      }

      nearest = alert;
      nearestScore = score;
    }

    return nearest;
  }

  static double? _alongRouteScore({
    required double? alongRouteM,
    required RiskAlert alert,
    required double leadM,
  }) {
    final segmentStart = alert.distanceFromRouteStartM;
    if (alongRouteM == null || segmentStart == null) {
      return null;
    }

    final segmentLength = alert.segmentLengthM ?? 0;
    final zoneStart = segmentStart - leadM;
    final zoneEnd = segmentStart + segmentLength + leadM * 0.35;
    if (alongRouteM < zoneStart || alongRouteM > zoneEnd) {
      return null;
    }

    if (alongRouteM < segmentStart) {
      return segmentStart - alongRouteM;
    }
    return alongRouteM - segmentStart;
  }

  static double? _gpsScore({
    required GeoPoint position,
    required RiskAlert alert,
    required double leadM,
  }) {
    if (alert.distanceFromRouteStartM != null &&
        alert.segmentLengthM != null) {
      return null;
    }

    final alertPoint = GeoPoint(lat: alert.latitude, lng: alert.longitude);
    final distance = NavigationEngine.distanceMeters(position, alertPoint);
    if (distance >= leadM) {
      return null;
    }
    return distance;
  }

  /// Returns the nearest non-dismissed alert within its severity threshold.
  static RiskAlert? nearestWithinThreshold({
    required GeoPoint position,
    required List<RiskAlert> alerts,
    required Set<String> dismissedIds,
    double? thresholdM,
  }) {
    if (alerts.isEmpty) {
      return null;
    }

    RiskAlert? nearest;
    var nearestDistance = double.infinity;

    for (final alert in alerts) {
      if (dismissedIds.contains(alert.id)) {
        continue;
      }

      final alertPoint = GeoPoint(lat: alert.latitude, lng: alert.longitude);
      final distance = NavigationEngine.distanceMeters(position, alertPoint);
      final limit = thresholdM ?? thresholdForSeverity(alert.severity);
      if (distance < limit && distance < nearestDistance) {
        nearest = alert;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  static bool isWithinThreshold({
    required GeoPoint position,
    required RiskAlert alert,
    double? thresholdM,
  }) {
    final alertPoint = GeoPoint(lat: alert.latitude, lng: alert.longitude);
    final limit = thresholdM ?? thresholdForSeverity(alert.severity);
    return NavigationEngine.distanceMeters(position, alertPoint) < limit;
  }

  static int? distanceMeters({
    required GeoPoint position,
    required RiskAlert alert,
    List<GeoPoint>? routePolyline,
  }) {
    final alongRouteM = routePolyline != null && routePolyline.length >= 2
        ? NavigationEngine.distanceAlongRouteM(position, routePolyline)
        : null;
    final segmentStart = alert.distanceFromRouteStartM;
    if (alongRouteM != null && segmentStart != null) {
      final delta = (segmentStart - alongRouteM).round();
      return delta > 0 ? delta : 0;
    }

    final alertPoint = GeoPoint(lat: alert.latitude, lng: alert.longitude);
    return NavigationEngine.distanceMeters(position, alertPoint).round();
  }
}
