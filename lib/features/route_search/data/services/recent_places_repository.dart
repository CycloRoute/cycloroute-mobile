import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/services/recent_places_api_service.dart';
import 'package:cyclerisk/features/route_search/data/services/recent_places_storage.dart';

class RecentPlacesRepository {
  RecentPlacesRepository({
    RecentPlacesApiService? apiService,
    RecentPlacesStorage? storage,
  }) : _apiService = apiService ?? RecentPlacesApiService(),
       _storage = storage ?? RecentPlacesStorage();

  final RecentPlacesApiService _apiService;
  final RecentPlacesStorage _storage;

  Future<List<PlaceSuggestion>> loadDestinations(String? accessToken) {
    return _load(type: 'destination', accessToken: accessToken);
  }

  Future<List<PlaceSuggestion>> loadOrigins(String? accessToken) {
    return _load(type: 'origin', accessToken: accessToken);
  }

  Future<({
    List<PlaceSuggestion> destinations,
    List<PlaceSuggestion> origins,
  })> saveRoutePlaces({
    required String accessToken,
    required PlaceSuggestion origin,
    required PlaceSuggestion destination,
  }) async {
    try {
      final destinationResponse = await _apiService.upsert(
        accessToken: accessToken,
        body: destination.toRecentPlaceRequest('destination'),
      );
      final originResponse = await _apiService.upsert(
        accessToken: accessToken,
        body: origin.toRecentPlaceRequest('origin'),
      );

      final destinations = destinationResponse.toPlaceSuggestions();
      final origins = originResponse.toPlaceSuggestions();
      await _storage.replaceDestinations(destinations);
      await _storage.replaceOrigins(origins);
      return (destinations: destinations, origins: origins);
    } on ApiException {
      final destinations = await _storage.saveDestination(destination);
      final origins = await _storage.saveOrigin(origin);
      return (destinations: destinations, origins: origins);
    }
  }

  Future<List<PlaceSuggestion>> clearDestinations(String? accessToken) async {
    if (_hasToken(accessToken)) {
      try {
        await _apiService.deleteByType(
          accessToken: accessToken!,
          type: 'destination',
        );
      } on ApiException {
        // Keep local cache clear even if API fails.
      }
    }

    await _storage.clearDestinations();
    return const [];
  }

  Future<List<PlaceSuggestion>> _load({
    required String type,
    required String? accessToken,
  }) async {
    if (_hasToken(accessToken)) {
      try {
        final items = await _apiService.getRecent(
          accessToken: accessToken!,
          type: type,
        );
        final places = items.map((item) => item.toPlaceSuggestion()).toList();
        if (type == 'origin') {
          await _storage.replaceOrigins(places);
        } else {
          await _storage.replaceDestinations(places);
        }
        return places;
      } on ApiException {
        return _loadFromCache(type);
      }
    }

    return _loadFromCache(type);
  }

  Future<List<PlaceSuggestion>> _loadFromCache(String type) {
    return type == 'origin'
        ? _storage.loadOrigins()
        : _storage.loadDestinations();
  }

  bool _hasToken(String? accessToken) =>
      accessToken != null && accessToken.isNotEmpty;
}
