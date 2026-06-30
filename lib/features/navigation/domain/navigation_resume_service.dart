import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/services/geolocation_service.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_launch_args.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_session.dart';
import 'package:cyclerisk/features/navigation/data/repositories/navigation_cache_repository.dart';
import 'package:cyclerisk/features/navigation/data/services/navigation_api_service.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class NavigationResumeService {
  NavigationResumeService({
    NavigationApiService? apiService,
    NavigationCacheRepository? cacheRepository,
    GeolocationService? geolocationService,
  }) : _apiService = apiService ?? NavigationApiService(),
       _cacheRepository = cacheRepository ?? NavigationCacheRepository(),
       _geolocationService = geolocationService ?? GeolocationService();

  final NavigationApiService _apiService;
  final NavigationCacheRepository _cacheRepository;
  final GeolocationService _geolocationService;

  Future<NavigationLaunchArgs?> tryBuildResumeArgs({
    required String accessToken,
  }) async {
    NavigationSession session;
    try {
      final active = await _apiService.getActiveSession(
        accessToken: accessToken,
      );
      if (active == null || active.status != NavigationSessionStatus.active) {
        return null;
      }
      session = active;
    } on ApiException {
      return null;
    }

    final cache = await _cacheRepository.read();
    if (cache != null && cache.session.id == session.id) {
      return NavigationLaunchArgs(
        session: session,
        activeRoute: cache.activeRoute,
        preference: cache.preference,
        bikeProfile: cache.bikeProfile,
        destination: session.destination,
        origin: cache.origin,
        originLabel: cache.originLabel,
        destinationLabel: cache.destinationLabel,
        resumeStepIndex: cache.currentStepIndex,
      );
    }

    final origin = await _resolveOrigin(session);
    if (origin == null) {
      return null;
    }

    try {
      final rerouted = await _apiService.reroute(
        accessToken: accessToken,
        origin: origin,
        destination: session.destination,
        preference: session.activeRouteId,
        bikeProfile: BikeProfile.urban,
      );

      return NavigationLaunchArgs(
        session: session,
        activeRoute: rerouted.route,
        preference: session.activeRouteId,
        bikeProfile: BikeProfile.urban,
        destination: session.destination,
        origin: origin,
      );
    } on ApiException {
      return null;
    }
  }

  Future<GeoPoint?> _resolveOrigin(NavigationSession session) async {
    if (session.lastKnown != null) {
      return session.lastKnown;
    }

    final fix = await _geolocationService.getCurrentLocationSnapshot();
    if (fix == null) {
      return null;
    }

    return GeoPoint(lat: fix.point.latitude, lng: fix.point.longitude);
  }
}
