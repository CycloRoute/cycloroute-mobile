import 'package:geolocator/geolocator.dart';

enum LocationAccessStatus {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled;

  bool get isGranted => this == LocationAccessStatus.granted;

  static LocationAccessStatus fromPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationAccessStatus.granted;
      case LocationPermission.deniedForever:
        return LocationAccessStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationAccessStatus.denied;
    }
  }
}
