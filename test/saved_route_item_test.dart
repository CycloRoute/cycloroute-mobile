import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavedRouteItem', () {
    test('parses embedded saved meta from route payload', () {
      final item = SavedRouteItem.fromJson({
        'id': 'abc',
        'name': 'Work commute',
        'route_id': 'balanced',
        'route_payload': {
          'route_id': 'balanced',
          'distance_m': 4200,
          'cyclo_score': 0.7,
          'coordinates': [
            {'lat': -12.1, 'lng': -77.0},
            {'lat': -12.2, 'lng': -77.1},
          ],
          SavedRouteMeta.storageKey: {
            'origin': {'lat': -12.1, 'lng': -77.0},
            'destination': {'lat': -12.2, 'lng': -77.1},
            'origin_label': 'Home',
            'destination_label': 'Office',
            'planning_preference': 'balanced',
            'bike_profile': 'urban',
          },
        },
      });

      expect(item.meta?.originLabel, 'Home');
      expect(item.meta?.destinationLabel, 'Office');
      expect(item.meta?.planningPreference, RoutePreference.balanced);
      expect(item.meta?.bikeProfile, BikeProfile.urban);
      expect(item.canNavigate, isTrue);
    });

    test('falls back to coordinates when meta is missing', () {
      final item = SavedRouteItem.fromJson({
        'id': 'abc',
        'name': 'Legacy route',
        'route_id': 'recommended',
        'route_payload': {
          'route_id': 'recommended',
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
    });
  });
}
