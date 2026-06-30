import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/utils/distance_format.dart';
import 'package:cyclerisk/core/utils/infrastructure_type_label.dart';
import 'package:cyclerisk/core/utils/route_segment_colors.dart';
import 'package:cyclerisk/features/navigation/domain/route_alerts_resolver.dart';
import 'package:cyclerisk/features/navigation/presentation/maneuver_icons.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_segment.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class RouteDetailPreviewPanel extends StatelessWidget {
  const RouteDetailPreviewPanel({
    super.key,
    required this.route,
    required this.l10n,
    required this.distanceFormat,
  });

  final RouteOption route;
  final AppLocalizations l10n;
  final DistanceFormat distanceFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.routeDetailTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _RouteTurnByTurnSection(
          route: route,
          l10n: l10n,
          distanceFormat: distanceFormat,
        ),
        const SizedBox(height: 12),
        _RouteSegmentsTableSection(
          route: route,
          l10n: l10n,
          distanceFormat: distanceFormat,
        ),
        const SizedBox(height: 12),
        _RouteAlertsSection(route: route, l10n: l10n),
      ],
    );
  }
}

class _RouteTurnByTurnSection extends StatefulWidget {
  const _RouteTurnByTurnSection({
    required this.route,
    required this.l10n,
    required this.distanceFormat,
  });

  final RouteOption route;
  final AppLocalizations l10n;
  final DistanceFormat distanceFormat;

  @override
  State<_RouteTurnByTurnSection> createState() => _RouteTurnByTurnSectionState();
}

class _RouteTurnByTurnSectionState extends State<_RouteTurnByTurnSection> {
  static const _collapsedLimit = 6;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final steps = widget.route.steps;
    final visibleSteps = _expanded || steps.length <= _collapsedLimit
        ? steps
        : steps.take(_collapsedLimit).toList();

    return _SectionCard(
      title: widget.l10n.turnByTurnTitle,
      child: steps.isEmpty
          ? Text(
              widget.l10n.noTurnByTurnSteps,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              children: [
                ...visibleSteps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.navigationCyan.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            maneuverIconForType(step.type),
                            color: AppColors.navigationCyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.instruction,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (step.name.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  step.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                widget.distanceFormat.formatStepDistance(
                                  step.distanceM.round(),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (steps.length > _collapsedLimit)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded
                            ? widget.l10n.showFewerSteps
                            : widget.l10n.showAllSteps(steps.length),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _RouteSegmentsTableSection extends StatelessWidget {
  const _RouteSegmentsTableSection({
    required this.route,
    required this.l10n,
    required this.distanceFormat,
  });

  final RouteOption route;
  final AppLocalizations l10n;
  final DistanceFormat distanceFormat;

  @override
  Widget build(BuildContext context) {
    final segments = route.segments ?? const <RouteSegment>[];

    return _SectionCard(
      title: l10n.routeSegmentsTitle,
      child: segments.isEmpty
          ? Text(
              l10n.noRouteSegments,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              children: [
                _SegmentTableHeader(l10n: l10n),
                const SizedBox(height: 8),
                ...segments.asMap().entries.map(
                  (entry) => _SegmentTableRow(
                    index: entry.key + 1,
                    segment: entry.value,
                    l10n: l10n,
                    distanceFormat: distanceFormat,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SegmentTableHeader extends StatelessWidget {
  const _SegmentTableHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        SizedBox(width: 28, child: Text('#', style: style)),
        Expanded(flex: 3, child: Text(l10n.segmentTableInfra, style: style)),
        Expanded(child: Text(l10n.distance, style: style, textAlign: TextAlign.end)),
        Expanded(child: Text(l10n.segmentTableScore, style: style, textAlign: TextAlign.end)),
        Expanded(child: Text(l10n.segmentTableCondition, style: style, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _SegmentTableRow extends StatelessWidget {
  const _SegmentTableRow({
    required this.index,
    required this.segment,
    required this.l10n,
    required this.distanceFormat,
  });

  final int index;
  final RouteSegment segment;
  final AppLocalizations l10n;
  final DistanceFormat distanceFormat;

  @override
  Widget build(BuildContext context) {
    final color = RouteSegmentColors.forSegment(
      condition: segment.condition,
      riskLevel: segment.riskLevel,
    );
    final scorePercent = (segment.cycloScore * 100).round();
    final conditionLabel = _conditionLabel(l10n, segment);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              InfrastructureTypeLabel.localized(l10n, segment.infrastructureType),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              distanceFormat.formatRouteDistance(segment.distanceM),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            child: Text(
              '$scorePercent',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _ConditionChip(label: conditionLabel, color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _conditionLabel(AppLocalizations l10n, RouteSegment segment) {
    final condition = segment.condition?.toLowerCase();
    if (condition != null && condition.isNotEmpty) {
      return switch (condition) {
        'good' => l10n.conditionGood,
        'regular' => l10n.conditionRegular,
        'poor' => l10n.conditionPoor,
        _ => condition,
      };
    }

    return switch (segment.riskLevel?.toLowerCase()) {
      'low' => l10n.riskLow,
      'medium' => l10n.riskMedium,
      'high' => l10n.riskHigh,
      _ => '—',
    };
  }
}

class _RouteAlertsSection extends StatelessWidget {
  const _RouteAlertsSection({
    required this.route,
    required this.l10n,
  });

  final RouteOption route;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final alerts = RouteAlertsResolver.resolve(route);

    return _SectionCard(
      title: l10n.alertsAlongRouteTitle,
      child: alerts.isEmpty
          ? Text(
              l10n.noRouteAlertsOnRoute,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              children: alerts
                  .map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AlertPreviewRow(alert: alert),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _AlertPreviewRow extends StatelessWidget {
  const _AlertPreviewRow({required this.alert});

  final RiskAlert alert;

  Color _severityColor() {
    return switch (alert.severity.toLowerCase()) {
      'high' => AppColors.alertRed,
      'medium' => AppColors.riskYellow,
      'low' => AppColors.safeGreen,
      _ => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
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
          if (alert.recommendation.isNotEmpty) ...[
            const SizedBox(height: 6),
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
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
