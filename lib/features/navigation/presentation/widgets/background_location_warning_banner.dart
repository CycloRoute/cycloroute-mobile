import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/models/navigation_location_access.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';

/// Shown during navigation when only while-in-use location was granted.
class BackgroundLocationWarningBanner extends StatelessWidget {
  const BackgroundLocationWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    if (locationProvider.navigationLocationAccess !=
        NavigationLocationAccess.foregroundOnly) {
      return const SizedBox.shrink();
    }

    final l10n = appL10n(context);

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFFFF4E5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => locationProvider.ensureNavigationAccess(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFB45309),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.navigationLimitedLocationWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                l10n.allowBackgroundLocation,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFB45309),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
