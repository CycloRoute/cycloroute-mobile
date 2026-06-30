import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/auth/presentation/widgets/auth_flow_widgets.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return AuthGradientScaffold(
      centerContent: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthPageHeader(
                  centered: true,
                  icon: Icons.directions_bike_rounded,
                  title: l10n.appName,
                  subtitle: l10n.authEntrySubtitle,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    AuthFeaturePill(
                      icon: Icons.alt_route_rounded,
                      label: l10n.authFeatureBikeInfra,
                      color: AppColors.safeGreen,
                      animationIndex: 0,
                    ),
                    AuthFeaturePill(
                      icon: Icons.route_rounded,
                      label: l10n.authFeatureSmartRoutes,
                      color: AppColors.primary,
                      animationIndex: 1,
                    ),
                    AuthFeaturePill(
                      icon: Icons.record_voice_over_rounded,
                      label: l10n.authFeatureTurnByTurn,
                      color: AppColors.navigationCyan,
                      animationIndex: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                AuthPrimaryButton(
                  label: l10n.createAccount,
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.register),
                ),
                const SizedBox(height: 12),
                AuthOutlinedButton(
                  label: l10n.alreadyHaveAccount,
                  icon: Icons.login_rounded,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
