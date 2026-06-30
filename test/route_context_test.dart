import 'package:cyclerisk/core/utils/route_segment_colors.dart';
import 'package:cyclerisk/features/navigation/domain/route_alert_proximity.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteOption route context parsing', () {
    test('parses segments, alerts_along_route and step segment', () {
      final route = RouteOption.fromJson(_enrichedRouteJson);

      expect(route.segments, hasLength(2));
      expect(route.segments!.first.fromIndex, 0);
      expect(route.segments!.first.toIndex, 1);
      expect(route.segments!.first.condition, 'good');
      expect(route.segments!.last.riskLevel, 'high');

      expect(route.alertsAlongRoute, hasLength(1));
      expect(route.alertsAlongRoute!.first.id, 'alert-seg-1');
      expect(route.alertsAlongRoute!.first.severity, 'high');
      expect(route.alertsAlongRoute!.first.segmentIndex, 1);

      final step = route.steps.first;
      expect(step.segment, isNotNull);
      expect(step.segment!.cycloScore, closeTo(0.68, 0.001));
      expect(step.segment!.infrastructureType, 'shared_lane');
    });

    test('parses legacy routes without new fields', () {
      final route = RouteOption.fromJson({
        'route_id': 'balanced',
        'distance_m': 1200,
        'cyclo_score': 0.7,
        'coordinates': [
          {'lat': -12.0, 'lng': -77.0},
          {'lat': -12.1, 'lng': -77.1},
        ],
        'legs': [
          {
            'distance_m': 1200,
            'duration_s': 300,
            'steps': [
              {
                'index': 0,
                'type': 'depart',
                'instruction': 'Sal',
                'name': 'Calle 1',
                'distance_m': 1200,
                'duration_s': 300,
                'bearing_before': 0,
                'bearing_after': 90,
                'location': {'lat': -12.0, 'lng': -77.0},
              },
            ],
          },
        ],
      });

      expect(route.segments, isNull);
      expect(route.alertsAlongRoute, isNull);
      expect(route.steps.first.segment, isNull);
    });
  });

  group('RouteAlertProximity', () {
    final alert = RiskAlert(
      id: 'alert-seg-1',
      type: 'road_risk',
      title: 'Risk ahead',
      message: 'Slow down',
      recommendation: 'Stay visible',
      severity: 'high',
      latitude: -12.051,
      longitude: -77.039,
      timestamp: DateTime(2026, 1, 1),
    );

    test('returns alert when GPS is within 80 m', () {
      final nearby = RouteAlertProximity.nearestWithinThreshold(
        position: const GeoPoint(lat: -12.05101, lng: -77.03901),
        alerts: [alert],
        dismissedIds: const {},
      );

      expect(nearby, isNotNull);
      expect(nearby!.id, 'alert-seg-1');
    });

    test('skips dismissed alerts', () {
      final nearby = RouteAlertProximity.nearestWithinThreshold(
        position: const GeoPoint(lat: -12.05101, lng: -77.03901),
        alerts: [alert],
        dismissedIds: const {'alert-seg-1'},
      );

      expect(nearby, isNull);
    });

    test('returns null when GPS is farther than 80 m', () {
      final nearby = RouteAlertProximity.nearestWithinThreshold(
        position: const GeoPoint(lat: -12.06, lng: -77.05),
        alerts: [alert],
        dismissedIds: const {},
      );

      expect(nearby, isNull);
    });
  });

  group('RouteSegmentColors', () {
    test('maps condition and risk to palette colors', () {
      expect(RouteSegmentColors.forCondition('good'), const Color(0xFF10B981));
      expect(RouteSegmentColors.forCondition('regular'), const Color(0xFFF59E0B));
      expect(RouteSegmentColors.forCondition('poor'), const Color(0xFFEF4444));
      expect(RouteSegmentColors.forRiskLevel('low'), const Color(0xFF10B981));
      expect(RouteSegmentColors.forRiskLevel('high'), const Color(0xFFEF4444));
      expect(
        RouteSegmentColors.forSegment(condition: 'good', riskLevel: 'high'),
        const Color(0xFF10B981),
      );
    });
  });
}

const _enrichedRouteJson = {
  'route_id': 'recommended',
  'distance_m': 500,
  'cyclo_score': 0.75,
  'coordinates': [
    {'lat': -12.05, 'lng': -77.04},
    {'lat': -12.051, 'lng': -77.039},
    {'lat': -12.052, 'lng': -77.038},
  ],
  'segments': [
    {
      'from_index': 0,
      'to_index': 1,
      'distance_m': 142.5,
      'cyclo_score': 0.82,
      'risk_level': 'low',
      'condition': 'good',
      'infrastructure_type': 'cycleway',
      'bike_infrastructure_coverage': 0.91,
    },
    {
      'from_index': 1,
      'to_index': 2,
      'distance_m': 130,
      'cyclo_score': 0.42,
      'risk_level': 'high',
      'condition': 'poor',
      'infrastructure_type': 'shared_lane',
      'bike_infrastructure_coverage': 0.35,
    },
  ],
  'alerts_along_route': [
    {
      'id': 'alert-seg-1',
      'type': 'road_risk',
      'title': 'Tramo con poco infraestructura ciclista',
      'message': 'Proximos 200 m comparten carril con trafico.',
      'recommendation': 'Reduce la velocidad y mantente visible.',
      'severity': 'high',
      'location': {'lat': -12.051, 'lng': -77.039},
      'segment_index': 1,
      'distance_from_route_start_m': 1250,
    },
  ],
  'legs': [
    {
      'distance_m': 500,
      'duration_s': 120,
      'steps': [
        {
          'index': 0,
          'type': 'depart',
          'instruction': 'Sal hacia el norte',
          'name': 'Calle 1',
          'distance_m': 250,
          'duration_s': 60,
          'bearing_before': 0,
          'bearing_after': 10,
          'location': {'lat': -12.05, 'lng': -77.04},
          'segment': {
            'cyclo_score': 0.68,
            'risk_level': 'medium',
            'condition': 'regular',
            'infrastructure_type': 'shared_lane',
            'bike_infrastructure_coverage': 0.55,
          },
        },
      ],
    },
  ],
};
