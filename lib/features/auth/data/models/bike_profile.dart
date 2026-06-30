enum BikeProfile {
  urban,
  mtb,
  electric;

  String get apiValue => name;

  static BikeProfile fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'mtb':
        return BikeProfile.mtb;
      case 'electric':
        return BikeProfile.electric;
      default:
        return BikeProfile.urban;
    }
  }
}
