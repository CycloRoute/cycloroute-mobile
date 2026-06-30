import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/engine_meta.dart';
import 'package:cyclerisk/features/navigation/data/models/map_match_response.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_session.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_options_result.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class NavigationApiService {
  NavigationApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<RouteOptionsResult> getRouteOptions({
    required GeoPoint origin,
    required GeoPoint destination,
    required String accessToken,
    String? originLabel,
    String? destinationLabel,
    RoutePreference? preference,
    BikeProfile? bikeProfile,
    String context = 'planning',
  }) async {
    final body = <String, dynamic>{
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'context': context,
    };
    if (preference != null) {
      body['preference'] = preference.apiValue;
    }
    if (bikeProfile != null) {
      body['bike_profile'] = bikeProfile.apiValue;
    }

    final response = await _apiClient.post(
      '/routes/options',
      accessToken: accessToken,
      body: body,
    );

    return RouteOptionsResult.fromJson(
      response,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      planningPreference: preference,
      bikeProfile: bikeProfile,
    );
  }

  Future<NavigationSession> startNavigation({
    required String accessToken,
    required GeoPoint destination,
    required RoutePreference activeRouteId,
    GeoPoint? origin,
  }) async {
    final body = <String, dynamic>{
      'destination': destination.toJson(),
      'active_route_id': activeRouteId.apiValue,
    };
    if (origin != null) {
      body['origin'] = origin.toJson();
    }

    final response = await _apiClient.post(
      '/routes/navigation/start',
      accessToken: accessToken,
      body: body,
    );

    return NavigationSession.fromJson(response);
  }

  Future<NavigationSession?> getActiveSession({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/routes/navigation/active',
      accessToken: accessToken,
    );

    final session = response['session'];
    if (session is! Map<String, dynamic>) {
      return null;
    }

    return NavigationSession.fromJson(session);
  }

  Future<MapMatchResponse> mapMatch({
    required String accessToken,
    required GeoPoint point,
    double? bearing,
    double? accuracyM,
  }) async {
    final body = <String, dynamic>{'point': point.toJson()};
    if (bearing != null && !bearing.isNaN && bearing >= 0) {
      body['bearing'] = bearing;
    }
    if (accuracyM != null && accuracyM > 0) {
      body['accuracy_m'] = accuracyM;
    }

    final response = await _apiClient.post(
      '/routes/map-match',
      accessToken: accessToken,
      body: body,
    );

    return MapMatchResponse.fromJson(response);
  }

  Future<({RouteOption route, EngineMeta? meta})> reroute({
    required String accessToken,
    required GeoPoint origin,
    required GeoPoint destination,
    required RoutePreference preference,
    BikeProfile? bikeProfile,
    double? bearing,
    double? accuracyM,
    bool fastReroute = true,
    String? sessionId,
  }) async {
    final body = <String, dynamic>{
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'preference': preference.apiValue,
      'fast_reroute': fastReroute,
    };
    if (sessionId != null && sessionId.isNotEmpty) {
      body['session_id'] = sessionId;
    }
    if (bikeProfile != null) {
      body['bike_profile'] = bikeProfile.apiValue;
    }
    if (bearing != null && !bearing.isNaN && bearing >= 0) {
      body['bearing'] = bearing;
    }
    if (accuracyM != null && accuracyM > 0) {
      body['accuracy_m'] = accuracyM;
    }

    final response = await _apiClient.post(
      '/routes/reroute',
      accessToken: accessToken,
      body: body,
    );

    final routeJson = response['route'];
    if (routeJson is! Map<String, dynamic>) {
      final routes = response['routes'];
      if (routes is List && routes.isNotEmpty) {
        final first = routes.first;
        if (first is Map<String, dynamic>) {
          return (
            route: RouteOption.fromJson(first),
            meta: EngineMeta.fromJson(
              response['engine_meta'] as Map<String, dynamic>?,
            ),
          );
        }
      }
      throw const FormatException('Missing route in reroute response');
    }

    return (
      route: RouteOption.fromJson(routeJson),
      meta: EngineMeta.fromJson(
        response['engine_meta'] as Map<String, dynamic>?,
      ),
    );
  }

  Future<NavigationSession> completeNavigation({
    required String accessToken,
    String? sessionId,
  }) async {
    final response = await _apiClient.post(
      '/routes/navigation/complete',
      accessToken: accessToken,
      body: sessionId == null ? <String, dynamic>{} : {'session_id': sessionId},
    );

    return NavigationSession.fromJson(response);
  }

  Future<NavigationSession> cancelNavigation({
    required String accessToken,
    String? sessionId,
  }) async {
    final response = await _apiClient.post(
      '/routes/navigation/cancel',
      accessToken: accessToken,
      body: sessionId == null ? <String, dynamic>{} : {'session_id': sessionId},
    );

    return NavigationSession.fromJson(response);
  }
}
