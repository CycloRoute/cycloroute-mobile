import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/features/infrastructure/presentation/widgets/infrastructure_admin_map_tab.dart';
import 'package:cyclerisk/features/map/presentation/utils/cyclo_map_styles.dart';
import 'package:cyclerisk/features/reports/presentation/widgets/obstacle_moderation_sheet.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class InfrastructureAdminScreen extends StatefulWidget {
  const InfrastructureAdminScreen({super.key});

  @override
  State<InfrastructureAdminScreen> createState() =>
      _InfrastructureAdminScreenState();
}

class _InfrastructureAdminScreenState extends State<InfrastructureAdminScreen>
    with SingleTickerProviderStateMixin {
  final InfrastructureApiService _api = InfrastructureApiService();
  late final TabController _tabController;

  String _statusFilter = 'pending';
  List<InfrastructureMapPoint> _points = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final l10n = appL10n(context);
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = l10n.pleaseSignInAgain;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final status = _statusFilter == 'all' ? null : _statusFilter;
      final points = await _api.getMapPoints(
        accessToken: token,
        status: status,
      );
      if (!mounted) return;
      setState(() => _points = points);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotLoadInfrastructure);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openModeration(InfrastructureMapPoint point) async {
    await showInfrastructureModerationSheet(
      context,
      point: point,
      api: _api,
      onChanged: _load,
    );
  }

  String _emptyMessage(AppLocalizations l10n) {
    switch (_statusFilter) {
      case 'pending':
        return l10n.infrastructureEmptyPending;
      case 'active':
        return l10n.infrastructureEmptyActive;
      case 'hidden':
        return l10n.infrastructureEmptyHidden;
      default:
        return l10n.infrastructureEmptyAll;
    }
  }

  String _statusLabel(AppLocalizations l10n, InfrastructureMapPoint point) {
    if (point.isPending) return l10n.moderationPending;
    if (point.isActive) return l10n.moderationActive;
    if (point.isHidden) return l10n.moderationHidden;
    return point.status ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.infrastructureAdminTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.infrastructureAdminListTab),
            Tab(text: l10n.infrastructureAdminMapTab),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  l10n.infrastructureAdminSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    FilterChip(
                      label: Text(l10n.moderationPending),
                      selected: _statusFilter == 'pending',
                      onSelected: (_) {
                        setState(() => _statusFilter = 'pending');
                        _load();
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.moderationActive),
                      selected: _statusFilter == 'active',
                      onSelected: (_) {
                        setState(() => _statusFilter = 'active');
                        _load();
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.moderationHidden),
                      selected: _statusFilter == 'hidden',
                      onSelected: (_) {
                        setState(() => _statusFilter = 'hidden');
                        _load();
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.moderationAll),
                      selected: _statusFilter == 'all',
                      onSelected: (_) {
                        setState(() => _statusFilter = 'all');
                        _load();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildListBody(l10n)),
            ],
          ),
          InfrastructureAdminMapTab(
            api: _api,
            statusFilter: _statusFilter,
            onRefresh: _load,
          ),
        ],
      ),
    );
  }

  Widget _buildListBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.alertRed),
          ),
        ),
      );
    }
    if (_points.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _emptyMessage(l10n),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _points.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final point = _points[index];
          final qualityColor =
              CycloMapStyles.infrastructureQualityColor(point.quality);

          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openModeration(point),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: qualityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${point.score}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: qualityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  point.quality,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                              _StatusChip(
                                label: _statusLabel(l10n, point),
                                point: point,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          if (point.authorName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.infrastructureSubmittedBy(point.authorName!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (point.createdAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(point.createdAt!),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.point});

  final String label;
  final InfrastructureMapPoint point;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (point.isPending) {
      color = AppColors.riskYellow;
    } else if (point.isActive) {
      color = AppColors.safeGreen;
    } else {
      color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
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
