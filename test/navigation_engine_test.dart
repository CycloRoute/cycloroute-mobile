import 'package:flutter_test/flutter_test.dart';
import 'package:cyclerisk/features/navigation/data/models/route_step.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_engine.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

void main() {
  group('NavigationEngine', () {
    final polyline = [
      const GeoPoint(lat: 0, lng: 0),
      const GeoPoint(lat: 0, lng: 0.001),
      const GeoPoint(lat: 0, lng: 0.002),
    ];

    test('isOffRoute returns false when snapped point is on polyline', () {
      expect(
        NavigationEngine.isOffRoute(
          const GeoPoint(lat: 0, lng: 0.001),
          polyline: polyline,
        ),
        isFalse,
      );
    });

    test('isOffRoute returns true when far from polyline', () {
      expect(
        NavigationEngine.isOffRoute(
          const GeoPoint(lat: 0.01, lng: 0.001),
          polyline: polyline,
          thresholdM: 40,
        ),
        isTrue,
      );
    });

    test('canReroute respects cooldown', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 2));
      expect(
        NavigationEngine.canReroute(lastRerouteAt: recent),
        isFalse,
      );
      expect(
        NavigationEngine.canReroute(
          lastRerouteAt: DateTime.now().subtract(const Duration(seconds: 10)),
        ),
        isTrue,
      );
    });

    test('shouldTriggerReroute uses streak and sustained off-route time', () {
      expect(
        NavigationEngine.shouldTriggerReroute(
          offRouteStreak: 1,
          offRouteSince: DateTime.now(),
          lastRerouteAt: null,
        ),
        isFalse,
      );
      expect(
        NavigationEngine.shouldTriggerReroute(
          offRouteStreak: 2,
          offRouteSince: DateTime.now(),
          lastRerouteAt: null,
        ),
        isTrue,
      );
      expect(
        NavigationEngine.shouldTriggerReroute(
          offRouteStreak: 1,
          offRouteSince: DateTime.now().subtract(const Duration(seconds: 4)),
          lastRerouteAt: null,
        ),
        isTrue,
      );
    });

    test('findCurrentStepIndex picks nearest maneuver', () {
      final steps = [
        RouteStep(
          index: 0,
          type: 'depart',
          instruction: 'Start',
          name: 'A',
          distanceM: 100,
          durationS: 30,
          bearingBefore: 0,
          bearingAfter: 90,
          location: const GeoPoint(lat: 0, lng: 0),
        ),
        RouteStep(
          index: 1,
          type: 'turn-right',
          instruction: 'Turn right',
          name: 'B',
          distanceM: 200,
          durationS: 40,
          bearingBefore: 90,
          bearingAfter: 180,
          location: const GeoPoint(lat: 0, lng: 0.002),
        ),
      ];

      expect(
        NavigationEngine.findCurrentStepIndex(
          const GeoPoint(lat: 0, lng: 0.0019),
          steps,
        ),
        1,
      );
    });
  });
}
