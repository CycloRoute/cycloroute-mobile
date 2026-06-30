import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';

class RouteOptionCard extends StatelessWidget {
  final RouteOption route;
  final VoidCallback onSelect;
  final bool isSelected;

  const RouteOptionCard({
    super.key,
    required this.route,
    required this.onSelect,
    this.isSelected = false,
  });

  Color _accentForInfra(double coverage) {
    if (coverage >= 0.5) {
      return AppColors.primary;
    }
    if (coverage >= 0.25) {
      return AppColors.navigationCyan;
    }
    return AppColors.textSecondary;
  }

  String _infraLabel(BuildContext context, double coverage) {
    final l10n = appL10n(context);
    if (coverage >= 0.5) {
      return l10n.routeInfraHigh;
    }
    if (coverage >= 0.25) {
      return l10n.routeInfraMedium;
    }
    return l10n.routeInfraLow;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final distanceFormat = distanceFormatOf(context);
    final infra = route.bikeInfrastructureCoverage;
    final accent = _accentForInfra(infra);
    final traceProgress = isSelected ? 1.0 : 0.0;
    final infraPercent = (infra * 100).round();
    final previewPoints = route.why.isNotEmpty
        ? route.why
        : [
            l10n.percentBikeInfra(infraPercent),
            route.condition ?? route.label ?? route.routeId,
          ];

    return InkWell(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        color: isSelected
            ? AppColors.primary.withOpacity(0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 7),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              route.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _infraLabel(context, infra),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Metric(
                            label: l10n.distance,
                            value: distanceFormat.formatRouteDistance(
                              route.distanceM,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _Metric(
                            label: l10n.time,
                            value: l10n.minutesShort(route.durationRounded),
                          ),
                          const SizedBox(width: 16),
                          _Metric(
                            label: l10n.bikeInfrastructure,
                            value: l10n.percentBikeInfra(infraPercent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        previewPoints.join('  ·  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.chevron_right_rounded,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
            AnimatedSize(
              duration: 320.ms,
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20, top: 14),
                      child: _RouteTrace(
                        route: route,
                        accent: accent,
                        progress: traceProgress,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (!isSelected) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: infra.clamp(0, 1),
                  minHeight: 3.5,
                  backgroundColor: AppColors.divider.withOpacity(0.65),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    accent.withOpacity(0.65),
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 180.ms),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _RouteTrace extends StatelessWidget {
  final RouteOption route;
  final Color accent;
  final double progress;

  const _RouteTrace({
    required this.route,
    required this.accent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                painter: _RouteTracePainter(
                  route: route,
                  accent: accent,
                  progress: animatedProgress,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: route.why.asMap().entries.map((entry) {
            final index = entry.key;
            final reason = entry.value;

            return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < route.why.length - 1 ? 8 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: index == 0 || index == route.why.length - 1
                              ? accent
                              : accent.withOpacity(0.75),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reason,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight:
                                    index == 0 || index == route.why.length - 1
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (70 * index).ms, duration: 260.ms)
                .slideX(begin: 0.03, end: 0);
          }).toList(),
        ),
      ],
    );
  }
}

class _RouteTracePainter extends CustomPainter {
  final RouteOption route;
  final Color accent;
  final double progress;

  _RouteTracePainter({
    required this.route,
    required this.accent,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()
      ..color = AppColors.divider.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final paintActive = Paint()
      ..color = accent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final fill = Paint()..color = accent;

    final left = 22.0;
    final top = 10.0;
    final usableHeight = size.height - top * 2;
    final pointCount = route.coordinates.length.clamp(2, 8);
    final step = usableHeight / (pointCount - 1).clamp(1, 999);
    final points = List<Offset>.generate(
      pointCount,
      (index) => Offset(left + (index.isEven ? 0 : 16), top + step * index),
    );

    for (var index = 0; index < points.length - 1; index++) {
      canvas.drawLine(points[index], points[index + 1], paintBase);
    }

    final totalSegments = points.length - 1;
    final activeDistance = totalSegments * progress;
    final activeSegments = activeDistance.floor();
    final segmentFraction = activeDistance - activeSegments;

    for (var index = 0; index < points.length - 1; index++) {
      if (index < activeSegments) {
        canvas.drawLine(points[index], points[index + 1], paintActive);
      } else if (index == activeSegments) {
        final start = points[index];
        final end = points[index + 1];
        final current = Offset.lerp(start, end, segmentFraction) ?? end;
        canvas.drawLine(start, current, paintActive);

        final glow = Paint()
          ..color = accent.withOpacity(0.24)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(current, 10, glow);
        canvas.drawCircle(current, 5, fill);
      }
    }

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final isActive = index <= (progress * (points.length - 1)).round();

      canvas.drawCircle(point, 7, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        4,
        Paint()..color = isActive ? accent : AppColors.divider,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteTracePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.route != route ||
        oldDelegate.accent != accent;
  }
}
