import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_marker_tap.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map.dart';
import 'package:cyclerisk/features/reports/presentation/widgets/obstacle_moderation_sheet.dart';

class InfrastructureAdminMapTab extends StatefulWidget {
  const InfrastructureAdminMapTab({
    super.key,
    required this.api,
    required this.statusFilter,
    required this.onRefresh,
  });

  final InfrastructureApiService api;
  final String statusFilter;
  final VoidCallback onRefresh;

  @override
  State<InfrastructureAdminMapTab> createState() =>
      _InfrastructureAdminMapTabState();
}

class _InfrastructureAdminMapTabState extends State<InfrastructureAdminMapTab> {
  final GlobalKey<CycloMapState> _mapKey = GlobalKey();

  @override
  void didUpdateWidget(covariant InfrastructureAdminMapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusFilter != widget.statusFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapKey.currentState?.refreshLayers();
      });
    }
  }

  void _refreshMap() {
    _mapKey.currentState?.refreshLayers();
    widget.onRefresh();
  }

  Future<void> _onMarkerTap(CycloMapMarkerTap tap) async {
    if (tap case CycloMapInfrastructureTap(:final point)) {
      await showInfrastructureModerationSheet(
        context,
        point: point,
        api: widget.api,
        onChanged: _refreshMap,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CycloMap(
      key: _mapKey,
      center: LatLng(-12.0464, -77.0428),
      zoom: 13,
      height: double.infinity,
      borderRadius: 0,
      layers: const CycloMapLayers(
        showUserLocation: true,
        showInfrastructureIa: true,
        showGraphCoverage: true,
        showPendingItems: true,
      ),
      mode: CycloMapMode.moderation,
      showLegend: true,
      moderationStatusFilter: widget.statusFilter,
      moderationTypeFilter: 'infra',
      onMarkerTap: _onMarkerTap,
    );
  }
}
