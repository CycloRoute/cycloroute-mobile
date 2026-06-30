import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';

class NavigationRiskAlertPrompt {
  const NavigationRiskAlertPrompt._();

  static String buildTts({
    required RiskAlert alert,
    required String prefix,
    int? distanceM,
    String Function(int meters)? distanceFormatter,
  }) {
    final parts = <String>[prefix.trim(), alert.title.trim()]
      ..removeWhere((part) => part.isEmpty);

    if (distanceM != null && distanceFormatter != null) {
      final distanceLabel = distanceFormatter(distanceM);
      if (distanceLabel.isNotEmpty) {
        parts.add(distanceLabel);
      }
    }

    final message = alert.message.trim();
    if (message.isNotEmpty) {
      parts.add(message);
    }

    final recommendation = alert.recommendation.trim();
    if (recommendation.isNotEmpty) {
      parts.add(recommendation);
    }

    return parts.join('. ');
  }

  static String notificationTitle(RiskAlert alert) => alert.title.trim();

  static String notificationBody(RiskAlert alert) {
    final recommendation = alert.recommendation.trim();
    if (recommendation.isNotEmpty) {
      return recommendation;
    }
    return alert.message.trim();
  }
}
