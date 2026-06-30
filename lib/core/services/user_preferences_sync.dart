import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/features/auth/data/models/auth_user.dart';

class UserPreferencesSync {
  const UserPreferencesSync._();

  static Future<void> applyFromUser({
    required AuthUser user,
    required BikeProfileProvider bikeProfileProvider,
    required NavigationPreferencesProvider navigationPreferencesProvider,
  }) async {
    await bikeProfileProvider.applyFromServer(user.defaultBikeProfile);
    await navigationPreferencesProvider.applyFromServer(
      voiceGuidanceEnabled: user.voiceGuidanceEnabled,
      voiceLanguage: user.voiceLanguage,
      distanceUnit: user.distanceUnit,
    );
  }

  static Future<void> applyFromAuthUserIfPresent({
    required AuthUser? user,
    required BikeProfileProvider bikeProfileProvider,
    required NavigationPreferencesProvider navigationPreferencesProvider,
  }) async {
    if (user == null) {
      return;
    }

    await applyFromUser(
      user: user,
      bikeProfileProvider: bikeProfileProvider,
      navigationPreferencesProvider: navigationPreferencesProvider,
    );
  }
}
