import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/models/saved_route_meta.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_options_result.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteApiService {
  RouteApiService({ApiClient? apiClient})
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
  }) async {
    final body = <String, dynamic>{
      'origin': origin.toJson(),
      'destination': destination.toJson(),
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

  Future<Map<String, dynamic>> saveRoute({
    required RouteOption selectedRoute,
    required String accessToken,
    required String name,
    SavedRouteMeta? meta,
  }) async {
    final payload = selectedRoute.toJson();
    if (meta != null) {
      payload[SavedRouteMeta.storageKey] = meta.toJson();
    }

    return _apiClient.post(
      '/routes/saved',
      accessToken: accessToken,
      body: {
        'name': name,
        'route_id': selectedRoute.routeId,
        'route_payload': payload,
      },
    );
  }

  Future<SavedRouteItem> updateSavedRoute({
    required String accessToken,
    required String id,
    required String name,
  }) async {
    final json = await _apiClient.patch(
      '/routes/saved/$id',
      accessToken: accessToken,
      body: {'name': name},
    );

    return SavedRouteItem.fromJson(json);
  }

  Future<void> deleteSavedRoute({
    required String accessToken,
    required String id,
  }) async {
    await _apiClient.delete(
      '/routes/saved/$id',
      accessToken: accessToken,
    );
  }

  Future<List<SavedRouteItem>> getSavedRoutes({
    required String accessToken,
  }) async {
    final decoded = await _apiClient.getRaw(
      '/routes/saved',
      accessToken: accessToken,
    );

    return _parseList(decoded, SavedRouteItem.fromJson);
  }

  Future<List<RouteHistoryItem>> getRouteHistory({
    required String accessToken,
  }) async {
    final decoded = await _apiClient.getRaw(
      '/routes/history',
      accessToken: accessToken,
    );

    return _parseList(decoded, RouteHistoryItem.fromJson);
  }

  Future<void> addRouteHistory({
    required String accessToken,
    required GeoPoint origin,
    required GeoPoint destination,
    required RouteOption selectedRoute,
    SavedRouteMeta? meta,
  }) async {
    final payload = selectedRoute.toJson();
    if (meta != null) {
      payload[SavedRouteMeta.storageKey] = meta.toJson();
    }

    await _apiClient.post(
      '/routes/history',
      accessToken: accessToken,
      body: {
        'origin': origin.toJson(),
        'destination': destination.toJson(),
        'selected_route': payload,
      },
    );
  }

  Future<List<RouteCoveragePoint>> getCoverage({
    required String accessToken,
    String? bounds,
  }) async {
    final path = bounds == null || bounds.isEmpty
        ? '/routes/coverage'
        : '/routes/coverage?bounds=$bounds';

    final decoded = await _apiClient.getRaw(path, accessToken: accessToken);
    return _parseList(decoded, RouteCoveragePoint.fromJson);
  }

  Future<Map<String, dynamic>> getEngineHealth({
    required String accessToken,
  }) async {
    final decoded = await _apiClient.getRaw(
      '/routes/engine-health',
      accessToken: accessToken,
    );

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'status': decoded?.toString() ?? 'unknown'};
  }

  Future<Map<String, dynamic>> getRouteOptionsDebug({
    required GeoPoint origin,
    required GeoPoint destination,
    required String accessToken,
  }) async {
    return _apiClient.post(
      '/routes/options/debug',
      accessToken: accessToken,
      body: {'origin': origin.toJson(), 'destination': destination.toJson()},
    );
  }

  List<T> _parseList<T>(
    dynamic decoded,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (decoded is! List) {
      return const [];
    }

    final items = <T>[];
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      try {
        items.add(fromJson(entry));
      } catch (_) {
        // Skip malformed history rows instead of failing the whole list.
      }
    }
    return items;
  }
}
