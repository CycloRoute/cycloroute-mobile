import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/locale_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/core/services/user_preferences_sync.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/localization_extensions.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/settings/data/models/navigation_preferences_l10n.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _syncProvidersFromAuth() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return;
    }

    await UserPreferencesSync.applyFromUser(
      user: user,
      bikeProfileProvider: context.read<BikeProfileProvider>(),
      navigationPreferencesProvider:
          context.read<NavigationPreferencesProvider>(),
    );
  }

  Future<void> _savePreferences({
    RoutePreference? routePreference,
    BikeProfile? bikeProfile,
    bool? voiceGuidanceEnabled,
    VoiceLanguageOption? voiceLanguage,
    DistanceUnit? distanceUnit,
    required String successMessage,
  }) async {
    final auth = context.read<AuthProvider>();
    final l10n = appL10n(context);

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final user = await auth.updateUserPreferences(
      defaultRoutePreference: routePreference,
      defaultBikeProfile: bikeProfile,
      voiceGuidanceEnabled: voiceGuidanceEnabled,
      voiceLanguage: voiceLanguage,
      distanceUnit: distanceUnit,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (user == null) {
      setState(
        () => _errorMessage =
            localizeAuthError(l10n, auth.lastApiError) ??
            l10n.couldNotUpdatePreference,
      );
      return;
    }

    await _syncProvidersFromAuth();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  Future<void> _updatePreference(RoutePreference preference) async {
    final auth = context.read<AuthProvider>();
    if (auth.defaultRoutePreference == preference) {
      return;
    }

    await _savePreferences(
      routePreference: preference,
      successMessage: appL10n(context).preferenceUpdated,
    );
  }

  Future<void> _updateBikeProfile(BikeProfile profile) async {
    final bikeProfileProvider = context.read<BikeProfileProvider>();
    if (bikeProfileProvider.profile == profile) {
      return;
    }

    await _savePreferences(
      bikeProfile: profile,
      successMessage: appL10n(context).bikeProfileUpdated,
    );
  }

  Future<void> _setLanguage(Locale? locale) async {
    await context.read<LocaleProvider>().setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final localeProvider = context.watch<LocaleProvider>();
    final bikeProfileProvider = context.watch<BikeProfileProvider>();
    final selectedLocale = localeProvider.overrideLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    RadioListTile<Locale?>(
                      value: null,
                      groupValue: selectedLocale,
                      onChanged: (value) => _setLanguage(value),
                      title: Text(l10n.languageSystem),
                    ),
                    RadioListTile<Locale?>(
                      value: const Locale('en'),
                      groupValue: selectedLocale,
                      onChanged: (value) => _setLanguage(value),
                      title: Text(l10n.languageEnglish),
                    ),
                    RadioListTile<Locale?>(
                      value: const Locale('es'),
                      groupValue: selectedLocale,
                      onChanged: (value) => _setLanguage(value),
                      title: Text(l10n.languageSpanish),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.defaultRoutePreference,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.defaultRoutePreferenceHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.alertRed),
                ),
                const SizedBox(height: 12),
              ],
              ...RoutePreference.values.map((preference) {
                final selected = auth.defaultRoutePreference == preference;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: RadioListTile<RoutePreference>(
                    value: preference,
                    groupValue: auth.defaultRoutePreference,
                    onChanged: _isSaving
                        ? null
                        : (_) => _updatePreference(preference),
                    title: Text(
                      preference.label(l10n),
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(preference.description(l10n)),
                  ),
                );
              }),
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 24),
              Text(
                l10n.myBike,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.myBikeHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...BikeProfile.values.map((profile) {
                final selected = bikeProfileProvider.profile == profile;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: RadioListTile<BikeProfile>(
                    value: profile,
                    groupValue: bikeProfileProvider.profile,
                    onChanged: _isSaving
                        ? null
                        : (_) => _updateBikeProfile(profile),
                    title: Text(
                      profile.label(l10n),
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(profile.description(l10n)),
                  ),
                );
              }),
              const SizedBox(height: 24),
              _NavigationPreferencesSection(
                l10n: l10n,
                isSaving: _isSaving,
                onVoiceGuidanceChanged: (enabled) => _savePreferences(
                  voiceGuidanceEnabled: enabled,
                  successMessage: l10n.preferenceUpdated,
                ),
                onVoiceLanguageChanged: (option) => _savePreferences(
                  voiceLanguage: option,
                  successMessage: l10n.preferenceUpdated,
                ),
              ),
              const SizedBox(height: 24),
              _DistanceUnitsSection(
                l10n: l10n,
                isSaving: _isSaving,
                onDistanceUnitChanged: (unit) => _savePreferences(
                  distanceUnit: unit,
                  successMessage: l10n.preferenceUpdated,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavigationPreferencesSection extends StatelessWidget {
  const _NavigationPreferencesSection({
    required this.l10n,
    required this.isSaving,
    required this.onVoiceGuidanceChanged,
    required this.onVoiceLanguageChanged,
  });

  final AppLocalizations l10n;
  final bool isSaving;
  final ValueChanged<bool> onVoiceGuidanceChanged;
  final ValueChanged<VoiceLanguageOption> onVoiceLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final navPrefs = context.watch<NavigationPreferencesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.navigationSettingsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: SwitchListTile(
            value: navPrefs.voiceGuidanceEnabled,
            onChanged: isSaving ? null : onVoiceGuidanceChanged,
            title: Text(l10n.voiceGuidance),
            subtitle: Text(l10n.voiceGuidanceHint),
          ),
        ),
        Text(
          l10n.voiceLanguage,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: VoiceLanguageOption.values.map((option) {
              return RadioListTile<VoiceLanguageOption>(
                value: option,
                groupValue: navPrefs.voiceLanguage,
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          onVoiceLanguageChanged(value);
                        }
                      },
                title: Text(option.label(l10n)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DistanceUnitsSection extends StatelessWidget {
  const _DistanceUnitsSection({
    required this.l10n,
    required this.isSaving,
    required this.onDistanceUnitChanged,
  });

  final AppLocalizations l10n;
  final bool isSaving;
  final ValueChanged<DistanceUnit> onDistanceUnitChanged;

  @override
  Widget build(BuildContext context) {
    final navPrefs = context.watch<NavigationPreferencesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.distanceUnits,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.distanceUnitsHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: DistanceUnit.values.map((unit) {
              return RadioListTile<DistanceUnit>(
                value: unit,
                groupValue: navPrefs.distanceUnit,
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          onDistanceUnitChanged(value);
                        }
                      },
                title: Text(unit.label(l10n)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
