import 'package:cyclerisk/l10n/app_localizations.dart';

class InfrastructureTypeLabel {
  const InfrastructureTypeLabel._();

  static String localized(AppLocalizations l10n, String? infrastructureType) {
    return switch (infrastructureType?.toLowerCase()) {
      'cycleway' => l10n.infraCycleway,
      'protected_lane' => l10n.infraProtectedLane,
      'shared_lane' => l10n.infraSharedLane,
      'bike_lane' => l10n.infraBikeLane,
      'living_street' => l10n.infraLivingStreet,
      'residential' => l10n.infraResidential,
      'primary' => l10n.infraPrimary,
      _ => l10n.infraUnknown,
    };
  }
}
