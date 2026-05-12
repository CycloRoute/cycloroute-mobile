import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';

class RiskLegendWidget extends StatelessWidget {
  const RiskLegendWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.riskLegend,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _RiskLevelItem(
          label: AppStrings.riskLow,
          color: AppColors.safeGreen,
          description: 'Safe roads',
        ),
        const SizedBox(height: 8),
        _RiskLevelItem(
          label: AppStrings.riskMedium,
          color: AppColors.riskYellow,
          description: 'Moderate hazards',
        ),
        const SizedBox(height: 8),
        _RiskLevelItem(
          label: AppStrings.riskHigh,
          color: AppColors.alertRed,
          description: 'High risk areas',
        ),
      ],
    );
  }
}

class _RiskLevelItem extends StatelessWidget {
  final String label;
  final Color color;
  final String description;

  const _RiskLevelItem({
    required this.label,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
