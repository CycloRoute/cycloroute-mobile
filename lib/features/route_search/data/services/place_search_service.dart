import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/services/places_api_service.dart';

/// Thin wrapper over [PlacesApiService] for route search screens.
class PlaceSearchService {
  PlaceSearchService({PlacesApiService? apiService})
    : _apiService = apiService ?? PlacesApiService();

  final PlacesApiService _apiService;

  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    required String accessToken,
    GeoPoint? near,
    int limit = 6,
  }) {
    return _apiService.search(
      accessToken: accessToken,
      query: query,
      near: near,
      limit: limit,
    );
  }

  Future<PlaceSuggestion> reverseGeocode(
    GeoPoint point, {
    required String accessToken,
  }) {
    return _apiService.reverse(
      accessToken: accessToken,
      point: point,
    );
  }
}
