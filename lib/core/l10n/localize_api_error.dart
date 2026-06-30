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

  final raw = exception.message.trim().toLowerCase();
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

  return exception.message;
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
