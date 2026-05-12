import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/data/mock/mock_routes.dart' as route_data;

class RouteOptionCard extends StatelessWidget {
  final route_data.Route route;
  final VoidCallback onSelect;
  final bool isSelected;

  const RouteOptionCard({
    Key? key,
    required this.route,
    required this.onSelect,
    this.isSelected = false,
  }) : super(key: key);

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return AppColors.safeGreen;
      case 'medium':
        return AppColors.riskYellow;
      case 'high':
        return AppColors.alertRed;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(route.riskLevel);

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.navigationCyan.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.navigationCyan : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: riskColor, width: 1),
                  ),
                  child: Text(
                    route.riskLevel.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: riskColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Distance',
                  value: '${route.distance.toStringAsFixed(1)} km',
                  context: context,
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                _StatItem(
                  label: 'Time',
                  value: '${route.duration} min',
                  context: context,
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                _StatItem(
                  label: 'Risk Score',
                  value: '${route.riskScore.toStringAsFixed(0)}',
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Risk score bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: route.riskScore / 100,
                minHeight: 4,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(riskColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _StatItem({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
