import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_results/data/models/route_segment.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

/// Builds [RiskAlert]s from route segments when the engine omits `alerts_along_route`.
class RouteAlertsBuilder {
  const RouteAlertsBuilder._();

  static const maxAlerts = 20;

  static List<RiskAlert> build({
    required List<RouteSegment> segments,
    required List<GeoPoint> coordinates,
  }) {
    if (segments.isEmpty || coordinates.length < 2) {
      return const [];
    }

    final candidates = <_Candidate>[];
    var distanceFromStart = 0.0;

    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (_qualifies(segment)) {
        final copy = _copyFor(segment);
        final location = _midpoint(coordinates, segment.fromIndex, segment.toIndex);
        candidates.add(
          _Candidate(
            cycloScore: segment.cycloScore,
            segmentIndex: index,
            alert: RiskAlert(
              id: 'alert-seg-$index',
              type: copy.type,
              title: copy.title,
              message: copy.message,
              recommendation: copy.recommendation,
              severity: copy.severity,
              latitude: location.lat,
              longitude: location.lng,
              timestamp: DateTime.now(),
              segmentIndex: index,
              distanceFromRouteStartM: distanceFromStart,
              segmentLengthM: segment.distanceM,
            ),
          ),
        );
      }
      distanceFromStart += segment.distanceM;
    }

    candidates.sort((a, b) {
      final scoreCompare = a.cycloScore.compareTo(b.cycloScore);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return a.segmentIndex.compareTo(b.segmentIndex);
    });

    return candidates.take(maxAlerts).map((item) => item.alert).toList();
  }

  static bool _qualifies(RouteSegment segment) {
    final risk = segment.riskLevel?.toLowerCase();
    final condition = segment.condition?.toLowerCase();
    final infra = segment.infrastructureType?.toLowerCase();

    if (risk == 'high' || condition == 'poor') {
      return true;
    }
    if ((infra == 'primary' || infra == 'unknown') && segment.cycloScore < 0.55) {
      return true;
    }
    if (risk == 'medium' && segment.cycloScore < 0.65) {
      return true;
    }
    if ((infra == 'primary' || infra == 'shared_lane') &&
        segment.cycloScore < 0.60) {
      return true;
    }
    return false;
  }

  static _AlertCopy _copyFor(RouteSegment segment) {
    final infra = segment.infrastructureType ?? 'unknown';
    final distance = segment.distanceM.round();
    final risk = segment.riskLevel?.toLowerCase() ?? 'medium';
    final condition = segment.condition?.toLowerCase() ?? 'regular';

    if (condition == 'poor' && risk == 'high') {
      return _AlertCopy(
        title: 'Tramo de alto riesgo',
        message:
            'Próximos $distance m presentan condiciones desfavorables para ciclistas.',
        recommendation:
            'Reduce la velocidad, mantente visible y evalúa un desvío si es posible.',
        severity: 'high',
      );
    }

    if (condition == 'poor') {
      return _AlertCopy(
        title: 'Tramo en mal estado para ciclistas',
        message:
            'Próximos $distance m tienen baja calidad de infraestructura ciclista.',
        recommendation: 'Circula con precaución y anticipa el tráfico.',
        severity: 'medium',
      );
    }

    if (risk == 'high') {
      return _AlertCopy(
        title: 'Tramo con riesgo elevado',
        message: 'Próximos $distance m requieren atención extra al transitar.',
        recommendation: 'Mantente alerta y usa señalización manual si giras.',
        severity: 'high',
      );
    }

    if (infra == 'primary' || infra == 'unknown') {
      return _AlertCopy(
        title: 'Tramo con poca infraestructura ciclista',
        message: 'Próximos $distance m comparten vía con tráfico vehicular.',
        recommendation: 'Reduce la velocidad y mantente visible.',
        severity: 'medium',
      );
    }

    return _AlertCopy(
      title: 'Tramo a revisar',
      message: 'Próximos $distance m pueden ser menos cómodos para pedalear.',
      recommendation: 'Mantente atento al entorno.',
      severity: 'medium',
    );
  }

  static GeoPoint _midpoint(
    List<GeoPoint> coordinates,
    int fromIndex,
    int toIndex,
  ) {
    final startIndex = fromIndex.clamp(0, coordinates.length - 1);
    final endIndex = toIndex.clamp(0, coordinates.length - 1);
    final start = coordinates[startIndex];
    final end = coordinates[endIndex];
    return GeoPoint(
      lat: (start.lat + end.lat) / 2,
      lng: (start.lng + end.lng) / 2,
    );
  }
}

class _Candidate {
  const _Candidate({
    required this.cycloScore,
    required this.segmentIndex,
    required this.alert,
  });

  final double cycloScore;
  final int segmentIndex;
  final RiskAlert alert;
}

class _AlertCopy {
  const _AlertCopy({
    required this.title,
    required this.message,
    required this.recommendation,
    required this.severity,
    this.type = 'road_risk',
  });

  final String type;
  final String title;
  final String message;
  final String recommendation;
  final String severity;
}
