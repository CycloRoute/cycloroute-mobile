import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';
import 'package:cyclerisk/features/reports/presentation/utils/obstacle_category_label.dart';
import 'package:cyclerisk/features/reports/presentation/utils/obstacle_expiry.dart';

Future<void> showObstacleDetailSheet(
  BuildContext context,
  ObstacleReport report,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => ObstacleDetailSheet(report: report),
  );
}

class ObstacleDetailSheet extends StatelessWidget {
  const ObstacleDetailSheet({super.key, required this.report});

  final ObstacleReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8C00),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ObstacleCategoryLabel.category(l10n, report.category),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (report.description.trim().isNotEmpty)
            Text(
              report.description.trim(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 12),
          _InfoRow(
            label: l10n.obstacleSeverityTitle,
            value: ObstacleCategoryLabel.severity(l10n, report.severity),
          ),
          if (report.isActive) ...[
            _InfoRow(
              label: l10n.obstacleTimeRemaining,
              value: ObstacleExpiry.formatRemaining(l10n, report.expiresAt),
            ),
            _InfoRow(
              label: l10n.obstacleVisibleUntilLabel,
              value: ObstacleExpiry.formatExpiresAt(l10n, report.expiresAt),
            ),
          ],
          if (report.createdAt != null)
            _InfoRow(
              label: l10n.obstacleReportedAt,
              value: _formatDate(report.createdAt!),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
