import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/services/user_preferences_sync.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/localization_extensions.dart';
import 'package:cyclerisk/features/onboarding/presentation/widgets/onboarding_flow_widgets.dart';

class BikeOnboardingScreen extends StatefulWidget {
  const BikeOnboardingScreen({super.key});

  @override
  State<BikeOnboardingScreen> createState() => _BikeOnboardingScreenState();
}

class _BikeOnboardingScreenState extends State<BikeOnboardingScreen> {
  BikeProfile _selected = BikeProfile.urban;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = context.read<BikeProfileProvider>().profile;
  }

  Future<void> _continue() async {
    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final user = await auth.updateUserPreferences(
      defaultBikeProfile: _selected,
    );

    if (!mounted) {
      return;
    }

    if (user != null) {
      await UserPreferencesSync.applyFromUser(
        user: user,
        bikeProfileProvider: context.read<BikeProfileProvider>(),
        navigationPreferencesProvider:
            context.read<NavigationPreferencesProvider>(),
      );
    } else {
      await context.read<BikeProfileProvider>().setProfile(_selected);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.preferenceOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return OnboardingScaffold(
      l10n: l10n,
      currentStep: 1,
      totalSteps: 2,
      headerIcon: Icons.directions_bike_rounded,
      title: l10n.myBike,
      subtitle: l10n.myBikeHint,
      options: [
        for (var index = 0; index < BikeProfile.values.length; index++)
          OnboardingOptionCard(
            selected: _selected == BikeProfile.values[index],
            icon: bikeProfileOnboardingIcon(BikeProfile.values[index]),
            accentColor: bikeProfileAccentColor(BikeProfile.values[index]),
            title: BikeProfile.values[index].label(l10n),
            description: BikeProfile.values[index].description(l10n),
            enabled: !_isSaving,
            animationIndex: index,
            onTap: () => setState(() => _selected = BikeProfile.values[index]),
          ),
      ],
      bottom: OnboardingPrimaryButton(
        label: l10n.continueButton,
        isLoading: _isSaving,
        onPressed: _isSaving ? null : _continue,
      ),
    );
  }
}
