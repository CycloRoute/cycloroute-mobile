import 'package:flutter_test/flutter_test.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_session.dart';
import 'package:cyclerisk/features/navigation/data/repositories/navigation_cache_repository.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

void main() {
  test('NavigationCacheData round-trips through json', () {
    final data = NavigationCacheData(
      session: NavigationSession(
        id: 'session-1',
        destination: const GeoPoint(lat: -12.12, lng: -77.03),
        activeRouteId: RoutePreference.recommended,
        status: NavigationSessionStatus.active,
        rerouteCount: 1,
        createdAt: DateTime.utc(2026, 6, 29, 12),
        updatedAt: DateTime.utc(2026, 6, 29, 12, 5),
        lastKnown: const GeoPoint(lat: -12.05, lng: -77.04),
      ),
      activeRoute: RouteOption(
        routeId: 'recommended',
        distanceM: 4200,
        cycloScore: 0.8,
        coordinates: const [
          GeoPoint(lat: -12.05, lng: -77.04),
          GeoPoint(lat: -12.12, lng: -77.03),
        ],
      ),
      preference: RoutePreference.recommended,
      bikeProfile: BikeProfile.electric,
      destination: const GeoPoint(lat: -12.12, lng: -77.03),
      destinationLabel: 'Miraflores',
      currentStepIndex: 2,
    );

    final restored = NavigationCacheData.fromJson(data.toJson());

    expect(restored.session.id, 'session-1');
    expect(restored.activeRoute.routeId, 'recommended');
    expect(restored.destinationLabel, 'Miraflores');
    expect(restored.currentStepIndex, 2);
    expect(restored.bikeProfile, BikeProfile.electric);
  });
}
