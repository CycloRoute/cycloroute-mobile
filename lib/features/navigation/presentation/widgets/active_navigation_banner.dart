import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/models/navigation_location_access.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_session_controller.dart';

class ActiveNavigationBanner extends StatelessWidget {
  const ActiveNavigationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationSessionController, LocationProvider>(
      builder: (context, session, locationProvider, _) {
        if (!session.isSessionActive) {
          return const SizedBox.shrink();
        }

        final l10n = appL10n(context);
        final limitedLocation =
            locationProvider.navigationLocationAccess ==
            NavigationLocationAccess.foregroundOnly;
        final destination = session.destinationLabel?.trim();
        final title = destination == null || destination.isEmpty
            ? l10n.activeNavigationTitle
            : l10n.navigatingTo(destination);
        final instruction = session.instruction.trim().isEmpty
            ? l10n.navigationNotificationActive
            : session.instruction.trim();
        final launchArgs = session.launchArgs;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: launchArgs == null
                ? null
                : () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.navigation,
                      arguments: launchArgs,
                    );
                  },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0088AA), Color(0xFF00A3C4)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navigationCyan.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          instruction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.activeNavigationTapHint,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                        if (limitedLocation) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.navigationLimitedLocationWarning,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFFFF4E5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
