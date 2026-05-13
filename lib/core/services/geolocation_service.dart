import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GeolocationService {
  static final GeolocationService _instance = GeolocationService._internal();

  factory GeolocationService() {
    return _instance;
  }

  GeolocationService._internal();

  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestPermissions();
      if (!hasPermission) return null;

      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        'Location fix: lat=${position.latitude}, lng=${position.longitude}, '
        'accuracy=${position.accuracy}, altitude=${position.altitude}, '
        'speed=${position.speed}, heading=${position.heading}, '
        'timestamp=${position.timestamp}',
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream().map((position) {
      debugPrint(
        'Location update: lat=${position.latitude}, lng=${position.longitude}, '
        'accuracy=${position.accuracy}, altitude=${position.altitude}, '
        'speed=${position.speed}, heading=${position.heading}, '
        'timestamp=${position.timestamp}',
      );
      return LatLng(position.latitude, position.longitude);
    });
  }
}
