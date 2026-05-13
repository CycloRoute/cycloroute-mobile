import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/services/geolocation_service.dart';

class LocationProvider extends ChangeNotifier {
  final GeolocationService _geolocationService = GeolocationService();
  LatLng? _currentLocation;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<LatLng>? _locationSubscription;

  LatLng? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _geolocationService.getCurrentLocation();
      _currentLocation = location;
      _error = location == null ? 'Unable to get location' : null;

      if (location != null) {
        debugPrint(
          'Current location ready: lat=${location.latitude}, lng=${location.longitude}',
        );
        startLocationUpdates();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startLocationUpdates() {
    if (_locationSubscription != null) {
      return;
    }

    debugPrint('Starting location stream updates');
    _locationSubscription = _geolocationService.getLocationStream().listen(
      (location) {
        _currentLocation = location;
        debugPrint(
          'Provider location updated: lat=${location.latitude}, lng=${location.longitude}',
        );
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
