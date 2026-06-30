import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/services/user_preferences_sync.dart';

Future<void> navigateAfterAuth(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  final user = await auth.refreshProfile();

  if (!context.mounted) {
    return;
  }

  await UserPreferencesSync.applyFromAuthUserIfPresent(
    user: user,
    bikeProfileProvider: context.read<BikeProfileProvider>(),
    navigationPreferencesProvider:
        context.read<NavigationPreferencesProvider>(),
  );

  if (!context.mounted) {
    return;
  }

  if (!auth.hasCompletedPreferenceOnboarding) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.bikeOnboarding);
    return;
  }

  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
}
