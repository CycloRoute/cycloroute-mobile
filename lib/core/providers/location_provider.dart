import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyclerisk/core/location/location_permission_coordinator.dart';
import 'package:cyclerisk/core/location/navigation_location_permission_coordinator.dart';
import 'package:cyclerisk/core/models/location_access_status.dart';
import 'package:cyclerisk/core/models/navigation_location_access.dart';
import 'package:cyclerisk/core/services/geolocation_service.dart';

class LocationProvider extends ChangeNotifier {
  final GeolocationService _geolocationService = GeolocationService();
  LatLng? _currentLocation;
  double? _currentHeading;
  double? _currentSpeed;
  double? _currentAccuracy;
  bool _isLoading = false;
  LocationAccessStatus _accessStatus = LocationAccessStatus.unknown;
  NavigationLocationAccess _navigationLocationAccess =
      NavigationLocationAccess.denied;
  StreamSubscription<LocationSnapshot>? _locationSubscription;
  Future<void>? _getCurrentLocationTask;

  LatLng? get currentLocation => _currentLocation;
  double? get currentHeading => _currentHeading;
  double? get currentSpeed => _currentSpeed;
  double? get currentAccuracy => _currentAccuracy;
  bool get isLoading => _isLoading;
  LocationAccessStatus get accessStatus => _accessStatus;
  NavigationLocationAccess get navigationLocationAccess =>
      _navigationLocationAccess;
  bool get hasLocationAccess => _accessStatus.isGranted;
  bool get hasNavigationBackgroundAccess =>
      _navigationLocationAccess.hasBackgroundAccess;

  Future<void> refreshAccessStatus() async {
    _accessStatus = await _geolocationService.resolveAccessStatus();
    notifyListeners();
  }

  Future<void> requestInitialAccessIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasAsked =
        prefs.getBool('hasAskedInitialLocationPermission') ?? false;

    if (hasAsked) {
      await refreshAccessStatus();
      if (_accessStatus.isGranted) {
        await getCurrentLocation();
      }
      return;
    }

    await prefs.setBool('hasAskedInitialLocationPermission', true);
    if (!context.mounted) {
      return;
    }

    await ensureAccess(context, showRationale: true);
  }

  Future<bool> ensureAccess(
    BuildContext context, {
    bool showRationale = true,
    bool requiredForContinue = false,
  }) async {
    final granted = await LocationPermissionCoordinator.ensureAccess(
      context,
      showRationale: showRationale,
      requiredForContinue: requiredForContinue,
    );

    _accessStatus = await _geolocationService.resolveAccessStatus();

    if (granted) {
      await getCurrentLocation();
    } else {
      notifyListeners();
    }

    return granted;
  }

  Future<NavigationLocationAccess> ensureNavigationAccess(
    BuildContext context, {
    bool allowForegroundOnly = true,
  }) async {
    final access = await NavigationLocationPermissionCoordinator.ensureForNavigation(
      context,
      allowForegroundOnly: allowForegroundOnly,
    );

    _navigationLocationAccess = access;
    _accessStatus = await _geolocationService.resolveAccessStatus();

    if (access.isUsable) {
      await getCurrentLocation();
    } else {
      notifyListeners();
    }

    return access;
  }

  Future<void> getCurrentLocation() {
    return _getCurrentLocationTask ??= _fetchCurrentLocation().whenComplete(() {
      _getCurrentLocationTask = null;
    });
  }

  Future<void> _fetchCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accessStatus = await _geolocationService.resolveAccessStatus();
      final snapshot = await _geolocationService.getCurrentLocationSnapshot();
      _currentLocation = snapshot?.point;
      _currentHeading = _validHeading(snapshot?.heading);
      _currentSpeed = snapshot?.speed;
      _currentAccuracy = snapshot?.accuracy;

      if (snapshot != null) {
        debugPrint(
          'Current location ready: lat=${snapshot.point.latitude}, lng=${snapshot.point.longitude}',
        );
        startLocationUpdates();
      } else {
        _locationSubscription?.cancel();
        _locationSubscription = null;
      }
    } catch (e) {
      debugPrint('LocationProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startLocationUpdates() {
    if (_locationSubscription != null || !_accessStatus.isGranted) {
      return;
    }

    debugPrint('Starting location stream updates');
    _locationSubscription = _geolocationService.getLocationStream().listen(
      (snapshot) {
        _currentLocation = snapshot.point;
        _currentHeading = _validHeading(snapshot.heading) ?? _currentHeading;
        _currentSpeed = snapshot.speed;
        _currentAccuracy = snapshot.accuracy;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );
  }

  double? _validHeading(double? heading) {
    if (heading == null || heading.isNaN || heading < 0) {
      return null;
    }
    return heading % 360;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
