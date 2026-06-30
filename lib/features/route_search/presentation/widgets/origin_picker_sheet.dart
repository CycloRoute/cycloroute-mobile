import 'package:flutter/material.dart';

import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
typedef OriginPickerAction = void Function(OriginPickerSheetAction action);

enum OriginPickerSheetAction {
  currentLocation,
  mapPick,
}

class OriginPickerSheet extends StatelessWidget {
  const OriginPickerSheet({
    super.key,
    required this.recentOrigins,
    required this.onSelectOrigin,
    required this.onAction,
  });

  final List<PlaceSuggestion> recentOrigins;
  final ValueChanged<PlaceSuggestion> onSelectOrigin;
  final OriginPickerAction onAction;

  static Future<void> show(
    BuildContext context, {
    required List<PlaceSuggestion> recentOrigins,
    required ValueChanged<PlaceSuggestion> onSelectOrigin,
    required OriginPickerAction onAction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OriginPickerSheet(
        recentOrigins: recentOrigins,
        onSelectOrigin: onSelectOrigin,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.chooseStartingPoint,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.near_me_rounded,
              title: l10n.useCurrentLocation,
              subtitle: l10n.gpsLocation,
              onTap: () {
                Navigator.of(context).pop();
                onAction(OriginPickerSheetAction.currentLocation);
              },
            ),
            _ActionTile(
              icon: Icons.map_outlined,
              title: l10n.setLocationOnMap,
              subtitle: l10n.dragMapToAdjustPin,
              onTap: () {
                Navigator.of(context).pop();
                onAction(OriginPickerSheetAction.mapPick);
              },
            ),
            if (recentOrigins.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.recentOrigins,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ...recentOrigins.map(
                (origin) => _ActionTile(
                  icon: Icons.history_rounded,
                  title: origin.localizedTitle(l10n),
                  subtitle: origin.subtitleFor(l10n),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectOrigin(origin);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
