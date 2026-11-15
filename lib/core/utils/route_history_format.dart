import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RouteHistoryFormat {
  const RouteHistoryFormat._();

  static String formatCompletedAt(DateTime date, String localeName) {
    return DateFormat.yMMMd(localeName).add_jm().format(date.toLocal());
  }

  static String formatDuration(
    AppLocalizations l10n, {
    double? traveledMinutes,
    required int plannedMinutes,
  }) {
    if (traveledMinutes == null) {
      return l10n.minutesShort(plannedMinutes);
    }
    if (traveledMinutes < 1) {
      return l10n.lessThanOneMinute;
    }
    return l10n.minutesShort(traveledMinutes.round());
  }
}
