import 'package:cyclerisk/features/navigation/domain/navigation_risk_alert_prompt.dart';
import 'package:cyclerisk/features/navigation/domain/route_alert_proximity.dart';
import 'package:cyclerisk/features/navigation/domain/route_alerts_builder.dart';
import 'package:cyclerisk/features/navigation/domain/route_alerts_resolver.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_segment.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteAlertsBuilder', () {
    test('builds alerts for poor and high-risk segments', () {
      final alerts = RouteAlertsBuilder.build(
        segments: const [
          RouteSegment(
            fromIndex: 0,
            toIndex: 1,
            distanceM: 100,
            cycloScore: 0.85,
            riskLevel: 'low',
            condition: 'good',
            infrastructureType: 'cycleway',
          ),
          RouteSegment(
            fromIndex: 1,
            toIndex: 2,
            distanceM: 200,
            cycloScore: 0.40,
            riskLevel: 'high',
            condition: 'poor',
            infrastructureType: 'primary',
          ),
        ],
        coordinates: const [
          GeoPoint(lat: 0, lng: 0),
          GeoPoint(lat: 1, lng: 1),
          GeoPoint(lat: 2, lng: 2),
        ],
      );

      expect(alerts, isNotEmpty);
      expect(alerts.first.segmentIndex, 1);
      expect(alerts.first.severity, 'high');
    });
  });

  group('RouteAlertsResolver', () {
    test('uses API alerts when present', () {
      final route = RouteOption.fromJson({
        'route_id': 'balanced',
        'distance_m': 500,
        'cyclo_score': 0.7,
        'coordinates': [
          {'lat': -12.0, 'lng': -77.0},
          {'lat': -12.1, 'lng': -77.1},
        ],
        'alerts_along_route': [
          {
            'id': 'alert-api',
            'type': 'road_risk',
            'title': 'API alert',
            'message': 'Message',
            'recommendation': 'Slow down',
            'severity': 'high',
            'location': {'lat': -12.05, 'lng': -77.05},
          },
        ],
      });

      final resolved = RouteAlertsResolver.resolve(route);
      expect(resolved, hasLength(1));
      expect(resolved.first.id, 'alert-api');
    });

    test('falls back to segment-derived alerts when API list is empty', () {
      final route = RouteOption.fromJson({
        'route_id': 'balanced',
        'distance_m': 500,
        'cyclo_score': 0.7,
        'coordinates': [
          {'lat': -12.0, 'lng': -77.0},
          {'lat': -12.1, 'lng': -77.1},
          {'lat': -12.2, 'lng': -77.2},
        ],
        'segments': [
          {
            'from_index': 0,
            'to_index': 1,
            'distance_m': 100,
            'cyclo_score': 0.85,
            'risk_level': 'low',
            'condition': 'good',
            'infrastructure_type': 'cycleway',
          },
          {
            'from_index': 1,
            'to_index': 2,
            'distance_m': 200,
            'cyclo_score': 0.40,
            'risk_level': 'high',
            'condition': 'poor',
            'infrastructure_type': 'primary',
          },
        ],
        'alerts_along_route': [],
      });

      final resolved = RouteAlertsResolver.resolve(route);
      expect(resolved, isNotEmpty);
      expect(resolved.first.id, 'alert-seg-1');
    });
  });

  group('RouteAlertProximity along route', () {
    test('triggers segment alert before reaching segment start', () {
      final alert = RiskAlert(
        id: 'seg-1',
        type: 'road_risk',
        title: 'Tramo de alto riesgo',
        message: 'Cuidado',
        recommendation: 'Reduce velocidad',
        severity: 'high',
        latitude: -12.05,
        longitude: -77.05,
        timestamp: DateTime(2026),
        distanceFromRouteStartM: 200,
        segmentLengthM: 150,
      );

      const polyline = [
        GeoPoint(lat: 0, lng: 0),
        GeoPoint(lat: 0, lng: 0.003),
        GeoPoint(lat: 0, lng: 0.006),
      ];

      final nearby = RouteAlertProximity.nearestForNavigation(
        position: const GeoPoint(lat: 0, lng: 0.0018),
        alerts: [alert],
        dismissedIds: {},
        routePolyline: polyline,
      );

      expect(nearby, isNotNull);
      expect(nearby!.id, 'seg-1');
    });
  });

  group('NavigationRiskAlertPrompt', () {
    test('builds TTS with prefix, distance and recommendation', () {
      final alert = RiskAlert(
        id: 'a1',
        type: 'road_risk',
        title: 'High risk segment',
        message: 'Poor conditions ahead',
        recommendation: 'Slow down',
        severity: 'high',
        latitude: 0,
        longitude: 0,
        timestamp: DateTime(2026),
      );

      final text = NavigationRiskAlertPrompt.buildTts(
        alert: alert,
        prefix: 'Route alert',
        distanceM: 80,
        distanceFormatter: (meters) => 'In $meters meters',
      );

      expect(text, contains('Route alert'));
      expect(text, contains('High risk segment'));
      expect(text, contains('In 80 meters'));
      expect(text, contains('Slow down'));
    });
  });
}
