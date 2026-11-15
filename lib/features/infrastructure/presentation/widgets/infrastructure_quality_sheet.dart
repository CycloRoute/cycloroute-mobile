import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:cyclerisk/features/map/presentation/utils/cyclo_map_styles.dart';

Future<void> showInfrastructureQualitySheet(
  BuildContext context,
  InfrastructureMapPoint point,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => InfrastructureQualitySheet(point: point),
  );
}

class InfrastructureQualitySheet extends StatelessWidget {
  const InfrastructureQualitySheet({super.key, required this.point});

  final InfrastructureMapPoint point;

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final qualityLabel = infrastructureQualityLabel(l10n, point.quality);
    final color = CycloMapStyles.infrastructureQualityColor(point.quality);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              qualityLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${point.score}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              l10n.analysisResultScoreLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String infrastructureQualityLabel(AppLocalizations l10n, String quality) {
  switch (quality.toUpperCase()) {
    case 'GOOD':
      return l10n.qualityGoodTitle;
    case 'BAD':
      return l10n.qualityBadTitle;
    default:
      return l10n.qualityRegularTitle;
  }
}
