import 'package:cyclerisk/l10n/app_localizations.dart';

String analysisQualityBody(
  AppLocalizations l10n, {
  required bool pending,
  required String quality,
}) {
  if (pending) {
    return l10n.graphImpactPendingDescription;
  }
  switch (quality.toUpperCase()) {
    case 'GOOD':
      return l10n.qualityGoodDescription;
    case 'BAD':
      return l10n.qualityBadDescription;
    default:
      return l10n.qualityRegularDescription;
  }
}

String analysisResultLead(
  AppLocalizations l10n, {
  required bool pending,
}) {
  return pending
      ? l10n.analysisResultPendingSubtitle
      : l10n.analysisResultSubtitle;
}
