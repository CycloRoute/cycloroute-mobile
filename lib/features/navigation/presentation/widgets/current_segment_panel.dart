import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/utils/route_segment_colors.dart';
import 'package:cyclerisk/features/navigation/data/models/route_step_segment.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class CurrentSegmentPanel extends StatelessWidget {
  const CurrentSegmentPanel({
    super.key,
    required this.segment,
    required this.l10n,
  });

  final RouteStepSegment segment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = _badgeLabel();
    if (badgeLabel == null) {
      return const SizedBox.shrink();
    }

    final badgeColor = RouteSegmentColors.forSegment(
      condition: segment.condition,
      riskLevel: segment.riskLevel,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.currentSegmentTitle,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _ContextChip(label: badgeLabel, color: badgeColor),
        ],
      ),
    );
  }

  String? _badgeLabel() {
    final condition = segment.condition?.toLowerCase();
    if (condition != null && condition.isNotEmpty) {
      return switch (condition) {
        'good' => l10n.conditionGood,
        'regular' => l10n.conditionRegular,
        'poor' => l10n.conditionPoor,
        _ => null,
      };
    }

    final risk = segment.riskLevel?.toLowerCase();
    return switch (risk) {
      'low' => l10n.riskLow,
      'medium' => l10n.riskMedium,
      'high' => l10n.riskHigh,
      _ => null,
    };
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
