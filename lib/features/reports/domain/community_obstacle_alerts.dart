import 'dart:math' as math;

import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class CommunityObstacleAlerts {
  const CommunityObstacleAlerts._();

  static const defaultRadiusM = 40.0;
  static const maxRadiusM = 2500.0;

  static Future<List<RiskAlert>> loadForRoute({
    required ReportsApiService apiService,
    required String accessToken,
    required List<GeoPoint> coordinates,
  }) async {
    if (coordinates.isEmpty) {
      return const [];
    }

    final center = _centroid(coordinates);
    final radiusM = _coverageRadiusM(center, coordinates)
        .clamp(defaultRadiusM, maxRadiusM);

    final reports = await apiService.getNearbyReports(
      accessToken: accessToken,
      lat: center.lat,
      lng: center.lng,
      radiusM: radiusM.round(),
    );

    return reports.where((report) => report.isActive).map(toRiskAlert).toList();
  }

  static RiskAlert toRiskAlert(ObstacleReport report) {
    final copy = _copyFor(report);
    return RiskAlert(
      id: 'community-${report.id}',
      type: 'community_obstacle',
      title: copy.title,
      message: report.description.trim().isEmpty
          ? copy.message
          : report.description.trim(),
      recommendation: copy.recommendation,
      severity: report.severity.apiValue,
      latitude: report.lat,
      longitude: report.lng,
      timestamp: report.createdAt ?? DateTime.now(),
    );
  }

  static GeoPoint _centroid(List<GeoPoint> coordinates) {
    var lat = 0.0;
    var lng = 0.0;
    for (final point in coordinates) {
      lat += point.lat;
      lng += point.lng;
    }
    return GeoPoint(
      lat: lat / coordinates.length,
      lng: lng / coordinates.length,
    );
  }

  static double _coverageRadiusM(GeoPoint center, List<GeoPoint> coordinates) {
    var maxDistance = defaultRadiusM;
    for (final point in coordinates) {
      final distance = _haversineM(
        center.lat,
        center.lng,
        point.lat,
        point.lng,
      );
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }
    return maxDistance + 180;
  }

  static double _haversineM(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusM = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthRadiusM * math.asin(math.sqrt(a));
  }

  static double _toRad(double deg) => deg * math.pi / 180.0;

  static _AlertCopy _copyFor(ObstacleReport report) {
    return switch (report.category) {
      ObstacleCategory.blockedLane => const _AlertCopy(
        title: 'Obstáculo en ciclovía',
        message: 'Hay un bloqueo reportado por la comunidad en esta zona.',
        recommendation:
            'Reduce la velocidad y prepárate para desviarte con seguridad.',
      ),
      ObstacleCategory.construction => const _AlertCopy(
        title: 'Obra o cierre reportado',
        message: 'Ciclistas reportaron obras o cierres en este tramo.',
        recommendation: 'Anticipa un desvío y sigue la señalización local.',
      ),
      ObstacleCategory.surfaceDamage => const _AlertCopy(
        title: 'Mal estado del pavimento',
        message: 'Se reportó daño en el pavimento en esta zona.',
        recommendation: 'Baja la velocidad y evita maniobras bruscas.',
      ),
      ObstacleCategory.debris => const _AlertCopy(
        title: 'Escombros o residuos en vía',
        message: 'Hay material u obstáculos reportados en el camino.',
        recommendation: 'Mantente alerta y cede el paso si es necesario.',
      ),
      ObstacleCategory.other => const _AlertCopy(
        title: 'Obstáculo reportado',
        message: 'La comunidad reportó un incidente en esta zona.',
        recommendation: 'Circula con precaución en este tramo.',
      ),
    };
  }
}

class _AlertCopy {
  const _AlertCopy({
    required this.title,
    required this.message,
    required this.recommendation,
  });

  final String title;
  final String message;
  final String recommendation;
}
