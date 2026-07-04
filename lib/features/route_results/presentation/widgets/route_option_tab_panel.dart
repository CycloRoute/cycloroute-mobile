import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/utils/distance_format.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_info_row.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_preview_panel.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

Color routeOptionAccentColor(String routeId) {
  return switch (routeId.toLowerCase()) {
    'recommended' => AppColors.primary,
    'balanced' => AppColors.navigationCyan,
    'shorter' => const Color(0xFF6366F1),
    _ => AppColors.textSecondary,
  };
}

class RouteOptionTabPanel extends StatelessWidget {
  const RouteOptionTabPanel({
    super.key,
    required this.route,
    required this.onStartNavigation,
    required this.startingNavigation,
  });

  final RouteOption route;
  final VoidCallback onStartNavigation;
  final bool startingNavigation;

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final distanceFormat = distanceFormatOf(context);
    final accent = routeOptionAccentColor(route.routeId);
    final cycloPercent = (route.cycloScore * 100).round();
    final infraPercent = (route.bikeInfrastructureCoverage * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MetricChip(
                      icon: Icons.straighten_rounded,
                      label: distanceFormat.formatRouteDistance(route.distanceM),
                    ),
                    const SizedBox(width: 8),
                    _MetricChip(
                      icon: Icons.schedule_rounded,
                      label: l10n.minutesShort(route.durationRounded),
                    ),
                    const SizedBox(width: 8),
                    _MetricChip(
                      icon: Icons.pedal_bike_outlined,
                      label: l10n.percentBikeInfra(infraPercent),
                      color: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RouteDetailInfoRow(
                  label: l10n.cycloScoreLabel,
                  value: '$cycloPercent',
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.selectedRouteSummary,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (route.why.isEmpty)
                  Text(
                    l10n.percentBikeInfra(infraPercent),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...route.why.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reason,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _openFullDetails(
                      context,
                      route: route,
                      l10n: l10n,
                      distanceFormat: distanceFormat,
                    ),
                    icon: const Icon(Icons.open_in_full_rounded, size: 18),
                    label: Text(l10n.routeDetailTitle),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: startingNavigation ? null : onStartNavigation,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: startingNavigation
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.startNavigation,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _openFullDetails(
    BuildContext context, {
    required RouteOption route,
    required AppLocalizations l10n,
    required DistanceFormat distanceFormat,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    route.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: RouteDetailPreviewPanel(
                        route: route,
                        l10n: l10n,
                        distanceFormat: distanceFormat,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RouteOptionTabChip extends StatelessWidget {
  const RouteOptionTabChip({
    super.key,
    required this.route,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  final RouteOption route;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = routeOptionAccentColor(route.routeId);

    return Expanded(
      child: Material(
        color: isSelected
            ? accent.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accent : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    route.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: accent,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textPrimary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: chipColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
