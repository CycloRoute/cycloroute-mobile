import 'package:cyclerisk/core/contracts/api_contracts.dart';
import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion_kind.dart';

class PlacesApiService implements PlacesApiContract {
  PlacesApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<List<PlaceSuggestion>> search({
    required String accessToken,
    required String query,
    GeoPoint? near,
    int limit = 6,
  }) async {
    final normalized = query.trim();
    if (normalized.length < 3) {
      return const [];
    }

    final params = <String, String>{
      'q': normalized,
      'limit': limit.clamp(1, 10).toString(),
    };
    if (near != null) {
      params['lat'] = near.lat.toString();
      params['lng'] = near.lng.toString();
    }

    final json = await _apiClient.get(
      '/places/search',
      accessToken: accessToken,
      queryParameters: params,
    );

    final rawItems = json['items'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(_placeFromJson)
        .toList();
  }

  Future<PlaceSuggestion> reverse({
    required String accessToken,
    required GeoPoint point,
  }) async {
    final json = await _apiClient.get(
      '/places/reverse',
      accessToken: accessToken,
      queryParameters: {
        'lat': point.lat.toString(),
        'lng': point.lng.toString(),
      },
    );

    return _placeFromJson(json, kind: PlaceSuggestionKind.mapPick);
  }

  PlaceSuggestion _placeFromJson(
    Map<String, dynamic> json, {
    PlaceSuggestionKind kind = PlaceSuggestionKind.search,
  }) {
    return PlaceSuggestion(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      point: GeoPoint.fromJson(json['point'] as Map<String, dynamic>),
      kind: kind,
    );
  }
}
