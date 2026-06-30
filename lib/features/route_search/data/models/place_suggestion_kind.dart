enum PlaceSuggestionKind {
  search,
  currentLocation,
  mapPick;

  String get storageValue => name;

  static PlaceSuggestionKind fromStorage(String? value) {
    return PlaceSuggestionKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => PlaceSuggestionKind.search,
    );
  }
}
