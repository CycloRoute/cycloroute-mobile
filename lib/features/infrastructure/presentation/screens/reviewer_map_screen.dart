import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_marker_tap.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/reports/presentation/widgets/obstacle_moderation_sheet.dart';
import 'package:latlong2/latlong.dart';

class ReviewerMapScreen extends StatefulWidget {
  const ReviewerMapScreen({super.key});

  @override
  State<ReviewerMapScreen> createState() => _ReviewerMapScreenState();
}

class _ReviewerMapScreenState extends State<ReviewerMapScreen> {
  final GlobalKey<CycloMapState> _mapKey = GlobalKey();
  final ReportsApiService _reportsApi = ReportsApiService();

  String _statusFilter = 'all';

  CycloMapLayers get _layers => const CycloMapLayers(
    showUserLocation: true,
    showCommunityObstacles: true,
    showPendingItems: true,
  );

  void _refreshMap() => _mapKey.currentState?.refreshLayers();

  Future<void> _onMarkerTap(CycloMapMarkerTap tap) async {
    if (tap case CycloMapObstacleTap(:final report)) {
      await showObstacleModerationSheet(
        context,
        report: report,
        api: _reportsApi,
        onChanged: _refreshMap,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final defaultCenter = LatLng(-12.0464, -77.0428);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviewerMap),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _refreshMap,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FilterChip(
                  label: Text(l10n.moderationPending),
                  selected: _statusFilter == 'pending',
                  onSelected: (_) => setState(() => _statusFilter = 'pending'),
                ),
                FilterChip(
                  label: Text(l10n.moderationActive),
                  selected: _statusFilter == 'active',
                  onSelected: (_) => setState(() => _statusFilter = 'active'),
                ),
                FilterChip(
                  label: Text(l10n.moderationAll),
                  selected: _statusFilter == 'all',
                  onSelected: (_) => setState(() => _statusFilter = 'all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: CycloMap(
              key: _mapKey,
              center: defaultCenter,
              zoom: 14,
              height: double.infinity,
              borderRadius: 0,
              layers: _layers,
              mode: CycloMapMode.moderation,
              showLegend: true,
              moderationStatusFilter: _statusFilter,
              moderationTypeFilter: 'obstacles',
              onMarkerTap: _onMarkerTap,
            ),
          ),
        ],
      ),
    );
  }
}
