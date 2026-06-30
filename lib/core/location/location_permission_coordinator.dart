import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/models/location_access_status.dart';
import 'package:cyclerisk/core/services/geolocation_service.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class LocationPermissionCoordinator {
  LocationPermissionCoordinator._();

  static final GeolocationService _geolocationService = GeolocationService();

  /// Requests location access when needed and guides the user if it is blocked.
  static Future<bool> ensureAccess(
    BuildContext context, {
    bool showRationale = true,
    bool requiredForContinue = false,
  }) async {
    final l10n = appL10n(context);
    var status = await _geolocationService.resolveAccessStatus();

    if (status.isGranted) {
      return true;
    }

    if (status == LocationAccessStatus.serviceDisabled) {
      final shouldOpen = await _confirm(
        context,
        title: l10n.locationServiceDisabledTitle,
        message: l10n.locationServiceDisabledMessage,
        confirmLabel: l10n.openLocationSettings,
      );
      if (shouldOpen) {
        await _geolocationService.openLocationSettings();
        status = await _geolocationService.resolveAccessStatus();
        if (status.isGranted) {
          return true;
        }
      }
      if (!requiredForContinue) {
        return false;
      }
      return status.isGranted;
    }

    if (status == LocationAccessStatus.deniedForever) {
      await _showDeniedForeverDialog(context, l10n);
      return (await _geolocationService.resolveAccessStatus()).isGranted;
    }

    if (showRationale) {
      final proceed = await _confirm(
        context,
        title: l10n.locationPermissionTitle,
        message: l10n.locationPermissionRationale,
        confirmLabel: l10n.enableLocation,
        cancelLabel: l10n.notNow,
      );
      if (!proceed) {
        return false;
      }
    }

    status = await _geolocationService.requestAccess();

    if (status.isGranted) {
      return true;
    }

    if (status == LocationAccessStatus.deniedForever) {
      await _showDeniedForeverDialog(context, l10n);
      return (await _geolocationService.resolveAccessStatus()).isGranted;
    }

    if (requiredForContinue && context.mounted) {
      await _confirm(
        context,
        title: l10n.locationPermissionDeniedTitle,
        message: l10n.locationPermissionDeniedMessage,
        confirmLabel: l10n.ok,
        showCancel: false,
      );
    }

    return false;
  }

  static Future<void> _showDeniedForeverDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final shouldOpen = await _confirm(
      context,
      title: l10n.locationPermissionDeniedForeverTitle,
      message: l10n.locationPermissionDeniedForeverMessage,
      confirmLabel: l10n.openAppSettings,
      cancelLabel: l10n.cancel,
    );

    if (shouldOpen) {
      await _geolocationService.openAppSettings();
    }
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    bool showCancel = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showCancel)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel ?? appL10n(context).cancel),
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
