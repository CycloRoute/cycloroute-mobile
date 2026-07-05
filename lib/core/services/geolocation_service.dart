import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/models/location_access_status.dart';

class LocationSnapshot {
  const LocationSnapshot({
    required this.point,
    required this.heading,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
  });

  final LatLng point;
  final double heading;
  final double speed;
  final double accuracy;
  final DateTime? timestamp;
}

class GeolocationService {
  static final GeolocationService _instance = GeolocationService._internal();

  factory GeolocationService() {
    return _instance;
  }

  GeolocationService._internal();

  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  Future<LocationAccessStatus> resolveAccessStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return LocationAccessStatus.fromPermission(permission);
  }

  Future<LocationPermission> getLocationPermission() {
    return Geolocator.checkPermission();
  }

  bool hasBackgroundLocationPermission(LocationPermission permission) {
    return permission == LocationPermission.always;
  }

  Future<LocationPermission> requestElevatedLocationPermission() {
    return Geolocator.requestPermission();
  }

  Future<LocationAccessStatus> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccessStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return LocationAccessStatus.fromPermission(permission);
  }

  Future<bool> requestPermissions() async {
    return (await requestAccess()).isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  Future<LatLng?> getCurrentLocation() async {
    final snapshot = await getCurrentLocationSnapshot();
    return snapshot?.point;
  }

  Future<LocationSnapshot?> getCurrentLocationSnapshot() async {
    try {
      final status = await resolveAccessStatus();
      if (!status.isGranted) {
        return null;
      }

      if (kIsWeb) {
        return _getCurrentLocationSnapshotWeb();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return _logAndSnapshot(position);
    } catch (e) {
      return _recoverFromLocationError(e);
    }
  }

  Future<LocationSnapshot?> _getCurrentLocationSnapshotWeb() async {
    final cached = await _readLastKnownSnapshot();
    if (cached != null) {
      return cached;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      return _logAndSnapshot(position);
    } catch (e) {
      return _recoverFromLocationError(e);
    }
  }

  Future<LocationSnapshot?> _readLastKnownSnapshot() async {
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) {
        return null;
      }
      return _toSnapshot(lastKnown);
    } catch (_) {
      return null;
    }
  }

  LocationSnapshot _logAndSnapshot(Position position) {
    debugPrint(
      'Location fix: lat=${position.latitude}, lng=${position.longitude}, '
      'accuracy=${position.accuracy}',
    );
    return _toSnapshot(position);
  }

  Future<LocationSnapshot?> _recoverFromLocationError(Object error) async {
    if (error is! TimeoutException) {
      debugPrint('Error getting location: $error');
    } else if (!kIsWeb) {
      debugPrint('Error getting location: $error');
    }

    return _readLastKnownSnapshot();
  }

  Stream<LocationSnapshot> getNavigationLocationStream({
    String notificationTitle = 'CycloRoute',
    String notificationText = 'Navegación activa',
    String notificationChannelName = 'CycloRoute Navigation',
  }) {
    return Geolocator.getPositionStream(
      locationSettings: _navigationSettings(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
        notificationChannelName: notificationChannelName,
      ),
    ).map(_toSnapshot);
  }

  Stream<LocationSnapshot> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map(_toSnapshot);
  }

  LocationSettings _navigationSettings({
    required String notificationTitle,
    required String notificationText,
    required String notificationChannelName,
  }) {
    if (kIsWeb) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: notificationTitle,
            notificationText: notificationText,
            notificationChannelName: notificationChannelName,
            enableWakeLock: true,
            setOngoing: true,
          ),
        );
      case TargetPlatform.iOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        );
    }
  }

  LocationSnapshot _toSnapshot(Position position) {
    return LocationSnapshot(
      point: LatLng(position.latitude, position.longitude),
      heading: position.heading,
      speed: position.speed,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }
}
