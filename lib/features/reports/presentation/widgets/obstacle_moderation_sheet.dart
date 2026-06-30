import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/reports/presentation/utils/obstacle_category_label.dart';
import 'package:cyclerisk/features/reports/presentation/utils/obstacle_expiry.dart';

typedef ModerationSheetCallback = void Function();

Future<void> showObstacleModerationSheet(
  BuildContext context, {
  required ObstacleReport report,
  required ReportsApiService api,
  required ModerationSheetCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => ObstacleModerationSheet(
      report: report,
      api: api,
      onChanged: () {
        Navigator.of(ctx).pop();
        onChanged();
      },
    ),
  );
}

Future<void> showInfrastructureModerationSheet(
  BuildContext context, {
  required InfrastructureMapPoint point,
  required InfrastructureApiService api,
  required ModerationSheetCallback onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => InfrastructureModerationSheet(
      point: point,
      api: api,
      onChanged: () {
        Navigator.of(ctx).pop();
        onChanged();
      },
    ),
  );
}

class ObstacleModerationSheet extends StatefulWidget {
  const ObstacleModerationSheet({
    super.key,
    required this.report,
    required this.api,
    required this.onChanged,
  });

  final ObstacleReport report;
  final ReportsApiService api;
  final ModerationSheetCallback onChanged;

  @override
  State<ObstacleModerationSheet> createState() =>
      _ObstacleModerationSheetState();
}

class _ObstacleModerationSheetState extends State<ObstacleModerationSheet> {
  late final TextEditingController _descriptionController;
  late ObstacleCategory _category;
  late ObstacleSeverity _severity;
  late int _activeDays;
  bool _editing = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.report.description);
    _category = widget.report.category;
    _severity = widget.report.severity;
    _activeDays = _daysFromExpiresAt(widget.report.expiresAt);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  int _daysFromExpiresAt(DateTime? expiresAt) {
    if (expiresAt == null) return ObstacleExpiry.defaultActiveDays;
    final days = expiresAt.difference(DateTime.now()).inDays;
    if (days <= 1) return 1;
    if (days <= 3) return 3;
    if (days <= 7) return 7;
    if (days <= 14) return 14;
    return 30;
  }

  Future<void> _approve() async {
    await _run(() => widget.api.updateReport(
          accessToken: _token(),
          reportId: widget.report.id,
          status: 'active',
          expiresAt: ObstacleExpiry.defaultExpiresAt(),
        ));
  }

  Future<void> _reject() async {
    await _run(() => widget.api.updateReport(
          accessToken: _token(),
          reportId: widget.report.id,
          status: 'dismissed',
        ));
  }

  Future<void> _saveEdit() async {
    await _run(() => widget.api.updateReport(
          accessToken: _token(),
          reportId: widget.report.id,
          description: _descriptionController.text.trim(),
          category: _category,
          severity: _severity,
          expiresAt: DateTime.now().add(Duration(days: _activeDays)),
        ));
  }

  Future<void> _delete() async {
    final l10n = appL10n(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteReport),
        content: Text(l10n.confirmDeleteReport),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.deleteReport,
              style: const TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _run(() => widget.api.deleteReport(
          accessToken: _token(),
          reportId: widget.report.id,
        ));
  }

  String _token() {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('missing token');
    }
    return token;
  }

  Future<void> _run(Future<void> Function() action) async {
    final l10n = appL10n(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      widget.onChanged();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.couldNotUpdateReport);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final report = widget.report;
    final isPending = report.isPending;
    final isActive = report.isActive;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.mapLayerObstacles,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (report.status != null) ...[
              const SizedBox(height: 4),
              Text(
                report.status!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_editing) ...[
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.obstacleCategoryTitle),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ObstacleCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text(ObstacleCategoryLabel.category(l10n, cat)),
                    selected: _category == cat,
                    onSelected: _busy ? null : (_) => setState(() => _category = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(l10n.obstacleSeverityTitle),
              SegmentedButton<ObstacleSeverity>(
                segments: ObstacleSeverity.values
                    .map(
                      (s) => ButtonSegment(
                        value: s,
                        label: Text(ObstacleCategoryLabel.severity(l10n, s)),
                      ),
                    )
                    .toList(),
                selected: {_severity},
                onSelectionChanged: _busy
                    ? null
                    : (v) => setState(() => _severity = v.first),
              ),
              const SizedBox(height: 12),
              Text(l10n.obstacleActiveDuration),
              DropdownButtonFormField<int>(
                value: _activeDays,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [1, 3, 7, 14, 30]
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text('$d'),
                      ),
                    )
                    .toList(),
                onChanged: _busy ? null : (v) => setState(() => _activeDays = v ?? 7),
              ),
            ] else ...[
              _DetailRow(l10n.description, report.description),
              _DetailRow(
                l10n.obstacleCategoryTitle,
                ObstacleCategoryLabel.category(l10n, report.category),
              ),
              _DetailRow(
                l10n.obstacleSeverityTitle,
                ObstacleCategoryLabel.severity(l10n, report.severity),
              ),
              if (isActive) ...[
                _DetailRow(
                  l10n.obstacleTimeRemaining,
                  ObstacleExpiry.formatRemaining(l10n, report.expiresAt),
                ),
                _DetailRow(
                  l10n.obstacleVisibleUntilLabel,
                  ObstacleExpiry.formatExpiresAt(l10n, report.expiresAt),
                ),
              ],
              if (report.reporterName != null)
                _DetailRow(l10n.obstacleAuthor, report.reporterName!),
              if (report.createdAt != null)
                _DetailRow(
                  l10n.obstacleReportedAt,
                  report.createdAt!.toLocal().toString(),
                ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.alertRed)),
            ],
            const SizedBox(height: 16),
            if (isPending && !_editing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _reject,
                      child: Text(l10n.moderationReject),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _approve,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.safeGreen,
                      ),
                      child: Text(l10n.moderationApprove),
                    ),
                  ),
                ],
              )
            else if (isActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_editing)
                    ElevatedButton(
                      onPressed: _busy ? null : _saveEdit,
                      child: Text(l10n.saveChanges),
                    )
                  else ...[
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => setState(() => _editing = true),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.editReport),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _delete,
                      icon: const Icon(Icons.delete_outline),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.alertRed,
                      ),
                      label: Text(l10n.deleteReport),
                    ),
                  ],
                ],
              )
            else if (report.isDismissed)
              OutlinedButton.icon(
                onPressed: _busy ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteReport),
              ),
            if (_editing && isActive)
              TextButton(
                onPressed: _busy ? null : () => setState(() => _editing = false),
                child: Text(l10n.cancel),
              ),
          ],
        ),
      ),
    );
  }
}

class InfrastructureModerationSheet extends StatefulWidget {
  const InfrastructureModerationSheet({
    super.key,
    required this.point,
    required this.api,
    required this.onChanged,
  });

  final InfrastructureMapPoint point;
  final InfrastructureApiService api;
  final ModerationSheetCallback onChanged;

  @override
  State<InfrastructureModerationSheet> createState() =>
      _InfrastructureModerationSheetState();
}

class _InfrastructureModerationSheetState
    extends State<InfrastructureModerationSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    final l10n = appL10n(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      widget.onChanged();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.couldNotUpdateReport);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _token() {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) throw StateError('missing token');
    return token;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final point = widget.point;

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
          Text(
            l10n.mapLayerInfrastructure,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow('Score', '${point.score}'),
          _DetailRow('Calidad', point.quality),
          if (point.status != null)
            _DetailRow(l10n.moderationPending, point.status!),
          if (point.authorName != null)
            _DetailRow(l10n.obstacleAuthor, point.authorName!),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: AppColors.alertRed)),
          const SizedBox(height: 16),
          if (point.isPending) ...[
            Text(
              l10n.infrastructureApproveGraphHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => widget.api.updateReportStatus(
                              accessToken: _token(),
                              reportId: point.id,
                              status: 'hidden',
                            )),
                    child: Text(l10n.moderationReject),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => widget.api.updateReportStatus(
                              accessToken: _token(),
                              reportId: point.id,
                              status: 'active',
                            )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.safeGreen,
                    ),
                    child: Text(l10n.moderationApprove),
                  ),
                ),
              ],
            ),
          ] else if (point.isHidden)
            OutlinedButton.icon(
              onPressed: _busy || point.id.isEmpty
                  ? null
                  : () => _run(() => widget.api.deleteReport(
                        accessToken: _token(),
                        reportId: point.id,
                      )),
              icon: const Icon(Icons.delete_outline),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.alertRed,
              ),
              label: Text(l10n.deleteReport),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
