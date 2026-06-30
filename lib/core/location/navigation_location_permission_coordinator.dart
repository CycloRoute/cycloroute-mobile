import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/location/location_permission_coordinator.dart';
import 'package:cyclerisk/core/models/navigation_location_access.dart';
import 'package:cyclerisk/core/services/geolocation_service.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

/// Navigation-specific permission flow: foreground location, then background /
/// always access and Android notification permission when needed.
class NavigationLocationPermissionCoordinator {
  NavigationLocationPermissionCoordinator._();

  static final GeolocationService _geolocationService = GeolocationService();

  static Future<NavigationLocationAccess> ensureForNavigation(
    BuildContext context, {
    bool allowForegroundOnly = true,
  }) async {
    final basicGranted = await LocationPermissionCoordinator.ensureAccess(
      context,
      showRationale: true,
      requiredForContinue: true,
    );
    if (!basicGranted) {
      return NavigationLocationAccess.denied;
    }

    if (kIsWeb) {
      return NavigationLocationAccess.background;
    }

    var permission = await _geolocationService.getLocationPermission();
    if (_geolocationService.hasBackgroundLocationPermission(permission)) {
      await _ensureAndroidNotificationPermission();
      return NavigationLocationAccess.background;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return NavigationLocationAccess.foregroundOnly;
    }

    if (!context.mounted) {
      return NavigationLocationAccess.denied;
    }

    final l10n = appL10n(context);
    final shouldRequest = await _confirm(
      context,
      title: l10n.navigationBackgroundPermissionTitle,
      message: l10n.navigationBackgroundPermissionMessage,
      confirmLabel: l10n.allowBackgroundLocation,
      cancelLabel: l10n.continueWithLimitedLocation,
    );

    if (!shouldRequest) {
      if (!allowForegroundOnly) {
        return NavigationLocationAccess.denied;
      }
      await _ensureAndroidNotificationPermission();
      return NavigationLocationAccess.foregroundOnly;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      permission = await _geolocationService.requestElevatedLocationPermission();
      if (!_geolocationService.hasBackgroundLocationPermission(permission) &&
          context.mounted) {
        await _showAndroidBackgroundSettingsGuide(context, l10n);
        permission = await _geolocationService.getLocationPermission();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Permission.locationAlways.request();
      permission = await _geolocationService.getLocationPermission();
      if (!_geolocationService.hasBackgroundLocationPermission(permission) &&
          context.mounted) {
        final openSettings = await _showIosAlwaysSettingsGuide(context, l10n);
        if (openSettings) {
          await _geolocationService.openAppSettings();
          permission = await _geolocationService.getLocationPermission();
        }
      }
    }

    await _ensureAndroidNotificationPermission();

    if (_geolocationService.hasBackgroundLocationPermission(permission)) {
      return NavigationLocationAccess.background;
    }

    return allowForegroundOnly
        ? NavigationLocationAccess.foregroundOnly
        : NavigationLocationAccess.denied;
  }

  static Future<void> _ensureAndroidNotificationPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final status = await Permission.notification.status;
    if (status.isGranted || status.isPermanentlyDenied) {
      return;
    }

    await Permission.notification.request();
  }

  static Future<void> _showAndroidBackgroundSettingsGuide(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final openSettings = await _confirm(
      context,
      title: l10n.navigationBackgroundSettingsTitle,
      message: l10n.navigationBackgroundSettingsMessageAndroid,
      confirmLabel: l10n.openAppSettings,
      cancelLabel: l10n.continueWithLimitedLocation,
    );

    if (openSettings) {
      await _geolocationService.openAppSettings();
    }
  }

  static Future<bool> _showIosAlwaysSettingsGuide(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    return _confirm(
      context,
      title: l10n.navigationBackgroundSettingsTitle,
      message: l10n.navigationBackgroundSettingsMessageIos,
      confirmLabel: l10n.openAppSettings,
      cancelLabel: l10n.continueWithLimitedLocation,
    );
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result == true;
  }
}
