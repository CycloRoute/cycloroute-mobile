import 'package:cyclerisk/core/services/api_error_keys.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

String localizeApiError(AppLocalizations l10n, ApiException exception) {
  final key = exception.errorKey;
  if (key != null) {
    switch (key) {
      case ApiErrorKeys.connectFailed:
        return l10n.couldNotConnectApi;
      case ApiErrorKeys.serviceUnavailable:
        return l10n.serviceUnavailable;
      case ApiErrorKeys.insufficientRole:
        return l10n.insufficientRole;
      case ApiErrorKeys.sessionExpired:
        return l10n.sessionExpired;
      case ApiErrorKeys.requestFailed:
        return l10n.requestFailed;
      case ApiErrorKeys.tooManyRequests:
        return l10n.tooManyRequests;
    }
  }

  final raw = '${exception.message} ${exception.detail ?? ''}'
      .trim()
      .toLowerCase();
  if (raw.isEmpty) {
    return _statusFallback(l10n, exception.statusCode);
  }

  if (raw.contains('invalid credentials')) {
    return l10n.invalidCredentials;
  }
  if (raw.contains('insufficient role')) {
    return l10n.insufficientRole;
  }
  if (raw.contains('invalid or expired reset')) {
    return l10n.invalidOrExpiredResetCode;
  }
  if (raw.contains('passwords do not match')) {
    return l10n.passwordsDoNotMatch;
  }
  if (raw.contains('new_password must be at least')) {
    return l10n.passwordMinLength;
  }
  if (raw.contains('cycloroute engine is not reachable') ||
      raw.contains('engine is not reachable')) {
    return l10n.serviceUnavailable;
  }

  final registration = _registrationMessage(l10n, raw);
  if (registration != null) {
    return registration;
  }
  if (raw.contains('no feasible route') ||
      raw.contains('no route found between')) {
    return l10n.noRouteOptionsFound;
  }

  return exception.message;
}

String localizePreferenceSaveError(
  AppLocalizations l10n,
  ApiException? exception,
) {
  if (exception == null ||
      exception.errorKey == ApiErrorKeys.connectFailed ||
      exception.errorKey == ApiErrorKeys.serviceUnavailable) {
    return l10n.couldNotUpdatePreference;
  }

  final localized = localizeApiError(l10n, exception);
  if (localized == l10n.couldNotConnectApi ||
      localized == l10n.serviceUnavailable) {
    return l10n.couldNotUpdatePreference;
  }
  return localized;
}

String? _registrationMessage(AppLocalizations l10n, String raw) {
  final isRegistration = raw.contains('could not register user') ||
      raw.contains('session could not be started') ||
      raw.contains('already been registered') ||
      raw.contains('already registered') ||
      raw.contains('email_exists') ||
      raw.contains('user already') ||
      raw.contains('invalid email') ||
      raw.contains('invalid format') ||
      raw.contains('unable to validate email') ||
      raw.contains('email_address_invalid');
  if (!isRegistration) {
    return null;
  }
  if (raw.contains('already been registered') ||
      raw.contains('already registered') ||
      raw.contains('email_exists') ||
      raw.contains('user already')) {
    return l10n.emailAlreadyRegistered;
  }
  if (raw.contains('invalid email') ||
      raw.contains('invalid format') ||
      raw.contains('unable to validate email') ||
      raw.contains('email_address_invalid')) {
    return l10n.invalidEmailAddress;
  }
  return l10n.registrationFailed;
}

String? localizeAuthError(AppLocalizations l10n, ApiException? exception) {
  if (exception == null) {
    return null;
  }
  return localizeApiError(l10n, exception);
}

String _statusFallback(AppLocalizations l10n, int? statusCode) {
  switch (statusCode) {
    case 401:
      return l10n.sessionExpired;
    case 403:
      return l10n.insufficientRole;
    case 502:
      return l10n.serviceUnavailable;
    case 429:
      return l10n.tooManyRequests;
    default:
      return l10n.requestFailed;
  }
}
