import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/presentation/utils/cyclo_map_styles.dart';

class CycloMapLegend extends StatelessWidget {
  const CycloMapLegend({
    super.key,
    required this.layers,
    required this.mode,
  });

  final CycloMapLayers layers;
  final CycloMapMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final items = <Widget>[];

    if (layers.showInfrastructureIa) {
      items.add(
        _LegendItem(
          color: AppColors.safeGreen,
          label: l10n.mapLayerInfrastructure,
        ),
      );
    }
    if (layers.showCommunityObstacles) {
      items.add(
        _LegendItem(
          color: CycloMapStyles.obstacleColor,
          label: l10n.mapLayerObstacles,
        ),
      );
    }
    if (layers.showGraphCoverage) {
      items.add(
        _LegendItem(
          color: AppColors.primary,
          label: l10n.mapLayerCoverage,
        ),
      );
    }
    if (mode == CycloMapMode.moderation && layers.showPendingItems) {
      items.add(
        _LegendItem(
          color: AppColors.textSecondary,
          label: l10n.moderationPending,
          dashed: true,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 1.5,
              style: dashed ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
