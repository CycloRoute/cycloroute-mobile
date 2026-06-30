import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

extension VoiceLanguageOptionL10n on VoiceLanguageOption {
  String label(AppLocalizations l10n) {
    switch (this) {
      case VoiceLanguageOption.system:
        return l10n.voiceLanguageSameAsApp;
      case VoiceLanguageOption.spanish:
        return l10n.languageSpanish;
      case VoiceLanguageOption.english:
        return l10n.languageEnglish;
    }
  }
}

extension DistanceUnitL10n on DistanceUnit {
  String label(AppLocalizations l10n) {
    switch (this) {
      case DistanceUnit.kilometers:
        return l10n.distanceUnitsKilometers;
      case DistanceUnit.miles:
        return l10n.distanceUnitsMiles;
    }
  }
}
