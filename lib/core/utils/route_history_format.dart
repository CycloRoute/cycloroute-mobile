import 'package:intl/intl.dart';

class RouteHistoryFormat {
  const RouteHistoryFormat._();

  static String formatCompletedAt(DateTime date, String localeName) {
    return DateFormat.yMMMd(localeName).add_jm().format(date.toLocal());
  }
}
