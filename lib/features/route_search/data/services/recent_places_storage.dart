import 'package:shared_preferences/shared_preferences.dart';

import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';

class RecentPlacesStorage {
  static const recentDestinationsKey = 'recent_destinations';
  static const recentOriginsKey = 'recent_origins';
  static const maxItems = 5;

  Future<List<PlaceSuggestion>> loadDestinations() =>
      _load(recentDestinationsKey);

  Future<List<PlaceSuggestion>> loadOrigins() => _load(recentOriginsKey);

  Future<List<PlaceSuggestion>> saveDestination(PlaceSuggestion place) =>
      _save(recentDestinationsKey, place);

  Future<List<PlaceSuggestion>> saveOrigin(PlaceSuggestion place) =>
      _save(recentOriginsKey, place);

  Future<void> clearDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(recentDestinationsKey);
  }

  Future<void> clearOrigins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(recentOriginsKey);
  }

  Future<void> replaceDestinations(List<PlaceSuggestion> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      recentDestinationsKey,
      items.map((item) => item.encode()).toList(),
    );
  }

  Future<void> replaceOrigins(List<PlaceSuggestion> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      recentOriginsKey,
      items.map((item) => item.encode()).toList(),
    );
  }

  Future<List<PlaceSuggestion>> _load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
            .getStringList(key)
            ?.map(PlaceSuggestion.tryDecode)
            .whereType<PlaceSuggestion>()
            .toList() ??
        const [];
  }

  Future<List<PlaceSuggestion>> _save(
    String key,
    PlaceSuggestion place,
  ) async {
    final existing = await _load(key);
    final updated = <PlaceSuggestion>[
      place,
      ...existing.where((item) => !item.isSameLocationAs(place)),
    ].take(maxItems).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      updated.map((item) => item.encode()).toList(),
    );
    return updated;
  }
}
