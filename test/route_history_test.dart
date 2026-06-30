import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteHistoryItem', () {
    test('parses route payload, meta and navigation endpoints', () {
      final item = RouteHistoryItem.fromJson({
        'id': 'hist-1',
        'route_id': 'recommended',
        'name': 'Ride to Miraflores',
        'created_at': '2026-06-29T18:30:00Z',
        'route_payload': {
          'route_id': 'recommended',
          'distance_m': 4200,
          'cyclo_score': 0.8,
          'coordinates': [
            {'lat': -12.1, 'lng': -77.0},
            {'lat': -12.2, 'lng': -77.1},
          ],
          SavedRouteMeta.storageKey: {
            'origin': {'lat': -12.1, 'lng': -77.0},
            'destination': {'lat': -12.2, 'lng': -77.1},
            'origin_label': 'Home',
            'destination_label': 'Miraflores',
            'planning_preference': 'recommended',
            'bike_profile': 'urban',
          },
        },
      });

      expect(item.displayTitle, 'Ride to Miraflores');
      expect(item.canNavigate, isTrue);
      expect(item.originLabel, 'Home');
      expect(item.destinationLabel, 'Miraflores');
      expect(item.meta?.planningPreference, RoutePreference.recommended);
      expect(item.meta?.bikeProfile, BikeProfile.urban);
      expect(item.routePayload?.distanceM, 4200);
      expect(item.createdAt, isNotNull);
    });

    test('falls back to coordinates when meta is missing', () {
      final item = RouteHistoryItem.fromJson({
        'id': 'hist-2',
        'route_id': 'balanced',
        'route_payload': {
          'route_id': 'balanced',
          'distance_m': 1000,
          'cyclo_score': 0.5,
          'coordinates': [
            {'lat': 1.0, 'lng': 2.0},
            {'lat': 3.0, 'lng': 4.0},
          ],
        },
      });

      expect(item.meta, isNull);
      expect(item.origin?.lat, 1.0);
      expect(item.destination?.lng, 4.0);
      expect(item.canNavigate, isTrue);
      expect(item.displayTitle, 'balanced');
    });

    test('parses backend selected_route with top-level origin and destination', () {
      final item = RouteHistoryItem.fromJson({
        'id': 'hist-3',
        'origin': {'lat': -12.1, 'lng': -77.0},
        'destination': {'lat': -12.2, 'lng': -77.1},
        'selected_route': {
          'route_id': 'recommended',
          'distance_m': 5200,
          'cyclo_score': 0.72,
          'coordinates': [
            {'lat': -12.1, 'lng': -77.0},
            {'lat': -12.2, 'lng': -77.1},
          ],
          SavedRouteMeta.storageKey: {
            'origin': {'lat': -12.1, 'lng': -77.0},
            'destination': {'lat': -12.2, 'lng': -77.1},
            'destination_label': 'Miraflores',
            'planning_preference': 'recommended',
            'bike_profile': 'urban',
          },
        },
        'created_at': '2026-06-29T20:00:00Z',
      });

      expect(item.routeId, 'recommended');
      expect(item.displayTitle, 'Miraflores');
      expect(item.canNavigate, isTrue);
      expect(item.routePayload?.distanceM, 5200);
    });
  });
}
