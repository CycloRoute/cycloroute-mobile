import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/auth/data/models/user_role.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

extension RoutePreferenceL10n on RoutePreference {  String label(AppLocalizations l10n) {
    switch (this) {
      case RoutePreference.recommended:
        return l10n.routePrefRecommended;
      case RoutePreference.balanced:
        return l10n.routePrefBalanced;
      case RoutePreference.shorter:
        return l10n.routePrefShorter;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case RoutePreference.recommended:
        return l10n.routePrefRecommendedDesc;
      case RoutePreference.balanced:
        return l10n.routePrefBalancedDesc;
      case RoutePreference.shorter:
        return l10n.routePrefShorterDesc;
    }
  }
}

extension BikeProfileL10n on BikeProfile {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BikeProfile.urban:
        return l10n.bikeProfileUrban;
      case BikeProfile.mtb:
        return l10n.bikeProfileMtb;
      case BikeProfile.electric:
        return l10n.bikeProfileElectric;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case BikeProfile.urban:
        return l10n.bikeProfileUrbanDesc;
      case BikeProfile.mtb:
        return l10n.bikeProfileMtbDesc;
      case BikeProfile.electric:
        return l10n.bikeProfileElectricDesc;
    }
  }
}

extension UserRoleL10n on UserRole {
  String label(AppLocalizations l10n) {
    switch (this) {
      case UserRole.reviewer:
        return l10n.roleReviewer;
      case UserRole.admin:
        return l10n.roleAdmin;
      case UserRole.user:
        return l10n.roleCyclist;
    }
  }
}
