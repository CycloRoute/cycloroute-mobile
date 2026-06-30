import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class ObstacleCategoryLabel {
  const ObstacleCategoryLabel._();

  static String category(AppLocalizations l10n, ObstacleCategory value) {
    return switch (value) {
      ObstacleCategory.blockedLane => l10n.obstacleCategoryBlockedLane,
      ObstacleCategory.construction => l10n.obstacleCategoryConstruction,
      ObstacleCategory.surfaceDamage => l10n.obstacleCategorySurfaceDamage,
      ObstacleCategory.debris => l10n.obstacleCategoryDebris,
      ObstacleCategory.other => l10n.obstacleCategoryOther,
    };
  }

  static String severity(AppLocalizations l10n, ObstacleSeverity value) {
    return switch (value) {
      ObstacleSeverity.low => l10n.obstacleSeverityLow,
      ObstacleSeverity.medium => l10n.obstacleSeverityMedium,
      ObstacleSeverity.high => l10n.obstacleSeverityHigh,
    };
  }
}
