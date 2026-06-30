enum RoutePreference {
  recommended,
  balanced,
  shorter;

  String get apiValue => name;

  static RoutePreference fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'balanced':
        return RoutePreference.balanced;
      case 'shorter':
        return RoutePreference.shorter;
      default:
        return RoutePreference.recommended;
    }
  }
}
