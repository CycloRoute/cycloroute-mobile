import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';

class ActiveAlertCard extends StatelessWidget {
  const ActiveAlertCard({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onTap,
    this.dismissLabel = 'Dismiss',
  });

  final RiskAlert alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final String dismissLabel;

  Color _severityColor(String severity) {
    return switch (severity.toLowerCase()) {
      'low' => AppColors.safeGreen,
      'medium' => AppColors.riskYellow,
      'high' => AppColors.alertRed,
      _ => AppColors.textSecondary,
    };
  }

  IconData _severityIcon(String severity) {
    return switch (severity.toLowerCase()) {
      'high' => Icons.warning_amber_rounded,
      'medium' => Icons.info_outline_rounded,
      _ => Icons.check_circle_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(alert.severity);
    final severityIcon = _severityIcon(alert.severity);

    return Material(
      color: AppColors.cardBackground,
      elevation: 4,
      shadowColor: AppColors.shadow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: severityColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(severityIcon, color: severityColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (alert.message.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            alert.message,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      tooltip: dismissLabel,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (alert.recommendation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  alert.recommendation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
