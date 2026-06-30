import 'package:cyclerisk/l10n/app_localizations.dart';

class ObstacleExpiry {
  const ObstacleExpiry._();

  static const defaultActiveDays = 7;

  static DateTime defaultExpiresAt([DateTime? from]) {
    return (from ?? DateTime.now()).add(
      const Duration(days: defaultActiveDays),
    );
  }

  static String formatRemaining(AppLocalizations l10n, DateTime? expiresAt) {
    if (expiresAt == null) {
      return l10n.obstacleNoExpiry;
    }

    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return l10n.obstacleExpired;
    }

    if (remaining.inDays >= 1) {
      return l10n.obstacleTimeRemainingDays(remaining.inDays);
    }
    if (remaining.inHours >= 1) {
      return l10n.obstacleTimeRemainingHours(remaining.inHours);
    }
    return l10n.obstacleTimeRemainingMinutes(
      remaining.inMinutes.clamp(1, 59),
    );
  }

  static String formatExpiresAt(AppLocalizations l10n, DateTime? expiresAt) {
    if (expiresAt == null) {
      return l10n.obstacleNoExpiry;
    }
    final local = expiresAt.toLocal();
    return l10n.obstacleVisibleUntil(
      '${local.day}/${local.month}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}',
    );
  }
}
