import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/features/auth/data/models/localization_extensions.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/onboarding/presentation/widgets/onboarding_flow_widgets.dart';

class PreferenceOnboardingScreen extends StatefulWidget {
  const PreferenceOnboardingScreen({super.key});

  @override
  State<PreferenceOnboardingScreen> createState() =>
      _PreferenceOnboardingScreenState();
}

class _PreferenceOnboardingScreenState
    extends State<PreferenceOnboardingScreen> {
  RoutePreference _selected = RoutePreference.recommended;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selected = context.read<AuthProvider>().defaultRoutePreference;
  }

  Future<void> _continue() async {
    final l10n = appL10n(context);

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final success = await context
        .read<AuthProvider>()
        .completePreferenceOnboarding(_selected);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (!success) {
      final lastError = context.read<AuthProvider>().lastApiError;
      setState(
        () => _errorMessage =
            localizeAuthError(l10n, lastError) ?? l10n.couldNotUpdatePreference,
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return OnboardingScaffold(
      l10n: l10n,
      currentStep: 2,
      totalSteps: 2,
      headerIcon: Icons.map_rounded,
      title: l10n.chooseDefaultRoute,
      subtitle: l10n.onboardingRouteHint,
      errorMessage: _errorMessage,
      options: [
        for (var index = 0; index < RoutePreference.values.length; index++)
          OnboardingOptionCard(
            selected: _selected == RoutePreference.values[index],
            icon: routePreferenceOnboardingIcon(RoutePreference.values[index]),
            accentColor: routePreferenceAccentColor(
              RoutePreference.values[index],
            ),
            title: RoutePreference.values[index].label(l10n),
            description: RoutePreference.values[index].description(l10n),
            enabled: !_isSaving,
            animationIndex: index,
            onTap: () =>
                setState(() => _selected = RoutePreference.values[index]),
          ),
      ],
      bottom: OnboardingPrimaryButton(
        label: l10n.onboardingFinishSetup,
        isLoading: _isSaving,
        onPressed: _isSaving ? null : _continue,
      ),
    );
  }
}
