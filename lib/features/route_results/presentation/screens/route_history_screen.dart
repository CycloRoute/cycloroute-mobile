import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/utils/route_history_format.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  final RouteApiService _routeApiService = RouteApiService();

  List<RouteHistoryItem> _items = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    final l10n = appL10n(context);
    final token = context.read<AuthProvider>().accessToken;
    if (token == null) {
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
      final items = await _routeApiService.getRouteHistory(accessToken: token);
      if (!mounted) return;
      final sorted = [...items]
        ..sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      setState(() => _items = sorted);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotLoadRouteHistory);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDetail(RouteHistoryItem item) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.routeHistoryDetail,
      arguments: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final distanceFormat = distanceFormatOf(context);
    final localeName = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeHistory),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _items.isEmpty
          ? RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                  _RouteHistoryEmptyState(
                    title: l10n.noRouteHistory,
                    hint: l10n.noRouteHistoryHint,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final route = item.routePayload;
                  final infraPercent =
                      ((route?.bikeInfrastructureCoverage ?? 0) * 100).round();
                  final metrics = <String>[
                    if (route != null)
                      distanceFormat.formatRouteDistance(route.distanceM),
                    if (route != null)
                      l10n.minutesShort(route.durationRounded),
                    if (route != null) l10n.percentBikeInfra(infraPercent),
                  ];
                  final dateLabel = item.createdAt == null
                      ? null
                      : RouteHistoryFormat.formatCompletedAt(
                          item.createdAt!,
                          localeName,
                        );

                  return Card(
                    child: ListTile(
                      title: Text(
                        item.displayTitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dateLabel != null) Text(dateLabel),
                          if (metrics.isNotEmpty) Text(metrics.join(' · ')),
                          if (dateLabel == null && metrics.isEmpty)
                            Text(item.routeId),
                        ],
                      ),
                      isThreeLine:
                          dateLabel != null && metrics.isNotEmpty,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openDetail(item),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _RouteHistoryEmptyState extends StatelessWidget {
  const _RouteHistoryEmptyState({
    required this.title,
    required this.hint,
  });

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
