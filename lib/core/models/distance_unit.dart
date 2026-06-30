enum DistanceUnit {
  kilometers,
  miles;

  String get storageValue => name;

  String get apiValue => name;

  static DistanceUnit fromApi(String? value) => fromStorage(value);

  static DistanceUnit fromStorage(String? value) {
    switch (value) {
      case 'miles':
        return DistanceUnit.miles;
      default:
        return DistanceUnit.kilometers;
    }
  }
}
