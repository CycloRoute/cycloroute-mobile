import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/models/location_access_status.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class LocationPermissionBanner extends StatelessWidget {
  const LocationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final locationProvider = context.watch<LocationProvider>();
    final status = locationProvider.accessStatus;

    if (status.isGranted || locationProvider.isLoading) {
      return const SizedBox.shrink();
    }

    final copy = locationPermissionBannerCopy(l10n, status);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => locationProvider.ensureAccess(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.location_off_outlined,
                color: AppColors.alertRed,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      copy.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.enableLocation,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPermissionBannerCopy {
  const LocationPermissionBannerCopy({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

LocationPermissionBannerCopy locationPermissionBannerCopy(
  AppLocalizations l10n,
  LocationAccessStatus status,
) {
  return switch (status) {
    LocationAccessStatus.deniedForever => LocationPermissionBannerCopy(
      title: l10n.locationPermissionDeniedForeverTitle,
      message: l10n.locationPermissionDeniedForeverMessage,
    ),
    LocationAccessStatus.serviceDisabled => LocationPermissionBannerCopy(
      title: l10n.locationServiceDisabledTitle,
      message: l10n.locationServiceDisabledMessage,
    ),
    _ => LocationPermissionBannerCopy(
      title: l10n.locationPermissionDeniedTitle,
      message: l10n.locationPermissionDeniedMessage,
    ),
  };
}
