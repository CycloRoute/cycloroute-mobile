import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class InfrastructureAnalysisResultArgs {
  const InfrastructureAnalysisResultArgs({
    required this.result,
    this.previewBytes,
  });

  final InfrastructureAnalysisResult result;
  final Uint8List? previewBytes;
}

class InfrastructureAnalysisResultScreen extends StatelessWidget {
  const InfrastructureAnalysisResultScreen({
    super.key,
    required this.args,
  });

  final InfrastructureAnalysisResultArgs args;

  InfrastructureAnalysisResult get result => args.result;

  Color _qualityColor(String quality) {
    switch (quality.toUpperCase()) {
      case 'GOOD':
        return AppColors.safeGreen;
      case 'BAD':
        return AppColors.alertRed;
      default:
        return AppColors.riskYellow;
    }
  }

  ({String title, String description}) _qualityCopy(
    AppLocalizations l10n,
    String quality,
  ) {
    switch (quality.toUpperCase()) {
      case 'GOOD':
        return (title: l10n.qualityGoodTitle, description: l10n.qualityGoodDescription);
      case 'BAD':
        return (title: l10n.qualityBadTitle, description: l10n.qualityBadDescription);
      default:
        return (
          title: l10n.qualityRegularTitle,
          description: l10n.qualityRegularDescription,
        );
    }
  }

  IconData _detectionIcon(String className) {
    final key = className.toLowerCase();
    if (key.contains('vehicle') || key.contains('car') || key.contains('truck')) {
      return Icons.directions_car_outlined;
    }
    if (key.contains('pedestrian') || key.contains('person')) {
      return Icons.directions_walk_rounded;
    }
    if (key.contains('bike') || key.contains('bicycle')) {
      return Icons.pedal_bike_rounded;
    }
    if (key.contains('sign') || key.contains('traffic')) {
      return Icons.traffic_outlined;
    }
    if (key.contains('light')) {
      return Icons.lightbulb_outline_rounded;
    }
    return Icons.visibility_outlined;
  }

  String _formatDetectionLabel(String className) {
    return className.replaceAll('_', ' ');
  }

  void _acceptAndGoHome(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final qualityColor = _qualityColor(result.quality);
    final qualityCopy = _qualityCopy(l10n, result.quality);
    final graph = result.graphUpdate;
    final preview = args.previewBytes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.analysisResultTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  l10n.analysisResultSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                if (preview != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      preview,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _ScoreHeroCard(
                  score: result.score,
                  quality: result.quality,
                  qualityColor: qualityColor,
                  qualityTitle: qualityCopy.title,
                  scoreLabel: l10n.analysisResultScoreLabel,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.insights_outlined,
                  iconColor: qualityColor,
                  title: qualityCopy.title,
                  body: qualityCopy.description,
                ),
                if (result.isPending) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.hourglass_top_rounded,
                    iconColor: AppColors.riskYellow,
                    title: l10n.infrastructurePendingReviewTitle,
                    body: l10n.infrastructurePendingReviewBody,
                  ),
                ],
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.hub_outlined,
                  iconColor: AppColors.primary,
                  title: l10n.graphImpactTitle,
                  body: result.isPending
                      ? l10n.graphImpactPendingDescription
                      : l10n.graphImpactDescription,
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _MetricRow(
                        icon: Icons.route_outlined,
                        label: result.isPending
                            ? l10n.graphEdgesWouldUpdate(
                                result.graphUpdate.edgesUpdated,
                              )
                            : l10n.graphEdgesUpdated(
                                result.graphUpdate.edgesUpdated,
                              ),
                      ),
                      if (graph.radiusM > 0) ...[
                        const SizedBox(height: 8),
                        _MetricRow(
                          icon: Icons.radio_button_unchecked,
                          label: l10n.graphRadiusDetail(graph.radiusM.round()),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _MetricRow(
                        icon: result.isGraphApplied
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        label: result.isPending
                            ? l10n.graphUpdatePendingApproval
                            : result.isGraphApplied
                            ? l10n.graphUpdateApplied
                            : l10n.graphUpdateNotApplied,
                        valueColor: result.isGraphApplied
                            ? AppColors.safeGreen
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (result.detections.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.center_focus_strong_outlined,
                    iconColor: AppColors.navigationCyan,
                    title: l10n.detections,
                    body: l10n.detectionsSubtitle,
                    footer: Column(
                      children: [
                        const SizedBox(height: 14),
                        ...result.detections.map(
                          (detection) => _DetectionTile(
                            icon: _detectionIcon(detection.className),
                            label: _formatDetectionLabel(detection.className),
                            confidence: detection.confidence,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  result.isPending
                      ? l10n.reportSubmittedForReview
                      : l10n.reportImprovedMap,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _acceptAndGoHome(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.acceptAndGoHome,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeroCard extends StatelessWidget {
  const _ScoreHeroCard({
    required this.score,
    required this.quality,
    required this.qualityColor,
    required this.qualityTitle,
    required this.scoreLabel,
  });

  final int score;
  final String quality;
  final Color qualityColor;
  final String qualityTitle;
  final String scoreLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            qualityColor.withValues(alpha: 0.12),
            qualityColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: qualityColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: qualityColor.withValues(alpha: 0.15),
                  color: qualityColor,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: qualityColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      scoreLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: qualityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              qualityTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: qualityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.footer,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetectionTile extends StatelessWidget {
  const _DetectionTile({
    required this.icon,
    required this.label,
    required this.confidence,
  });

  final IconData icon;
  final String label;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).round().clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceLight,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
