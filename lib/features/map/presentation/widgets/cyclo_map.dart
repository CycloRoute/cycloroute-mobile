import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:cyclerisk/core/config/app_config.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_marker_tap.dart';
import 'package:cyclerisk/features/map/presentation/utils/cyclo_map_styles.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map_legend.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';

class CycloMap extends StatefulWidget {
  static const double maxDisplayZoom = 20;
  static const int maxTileZoom = 18;

  const CycloMap({
    super.key,
    required this.center,
    this.zoom = 13,
    this.height = 280,
    this.mapController,
    this.polylines = const [],
    this.extraMarkers = const [],
    this.layers = const CycloMapLayers(),
    this.mode = CycloMapMode.user,
    this.rotation = 0,
    this.borderRadius = 12,
    this.showLegend = false,
    this.showCenterPin = false,
    this.centerPinIcon = Icons.location_pin,
    this.centerPinColor = AppColors.alertRed,
    this.userLocation,
    this.onBoundsChanged,
    this.onMarkerTap,
    this.onPositionChanged,
    this.moderationStatusFilter,
    this.moderationTypeFilter,
    this.followCenter = true,
    ReportsApiService? reportsApiService,
    InfrastructureApiService? infrastructureApiService,
    RouteApiService? routeApiService,
  })  : _reportsApiService = reportsApiService,
        _infrastructureApiService = infrastructureApiService,
        _routeApiService = routeApiService,
        super();

  final LatLng center;
  final double zoom;
  final double height;
  final MapController? mapController;
  final List<Polyline> polylines;
  final List<Marker> extraMarkers;
  final CycloMapLayers layers;
  final CycloMapMode mode;
  final double rotation;
  final double borderRadius;
  final bool showLegend;
  final bool showCenterPin;
  final IconData centerPinIcon;
  final Color centerPinColor;
  final LatLng? userLocation;
  final void Function(String bounds)? onBoundsChanged;
  final void Function(CycloMapMarkerTap tap)? onMarkerTap;
  final void Function(MapPosition position, bool hasGesture)? onPositionChanged;
  final String? moderationStatusFilter;
  final String? moderationTypeFilter;
  final bool followCenter;
  final ReportsApiService? _reportsApiService;
  final InfrastructureApiService? _infrastructureApiService;
  final RouteApiService? _routeApiService;

  @override
  State<CycloMap> createState() => CycloMapState();
}

class CycloMapState extends State<CycloMap> {
  late MapController _mapController;

  final ReportsApiService _defaultReportsApi = ReportsApiService();
  final InfrastructureApiService _defaultInfraApi = InfrastructureApiService();
  final RouteApiService _defaultRouteApi = RouteApiService();

  List<ObstacleReport> _obstacles = const [];
  List<InfrastructureMapPoint> _infraPoints = const [];
  List<RouteCoveragePoint> _coveragePoints = const [];
  bool _loadingLayers = false;
  Timer? _boundsDebounce;
  LatLng? _lastMovedCenter;
  double? _lastMovedZoom;
  double? _lastMovedRotation;
  DateTime? _lastCameraMoveAt;

  ReportsApiService get _reportsApi =>
      widget._reportsApiService ?? _defaultReportsApi;

  InfrastructureApiService get _infraApi =>
      widget._infrastructureApiService ?? _defaultInfraApi;

  RouteApiService get _routeApi => widget._routeApiService ?? _defaultRouteApi;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLayers();
      _notifyBounds();
    });
  }

  @override
  void didUpdateWidget(covariant CycloMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layers != widget.layers ||
        oldWidget.mode != widget.mode ||
        oldWidget.moderationStatusFilter != widget.moderationStatusFilter ||
        oldWidget.moderationTypeFilter != widget.moderationTypeFilter) {
      _loadLayers();
    }
    if (widget.followCenter && _shouldMoveMap(oldWidget)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentZoom = _safeZoom(_mapController.zoom);
        final zoomChanged = oldWidget.zoom != widget.zoom;
        final targetZoom =
            zoomChanged ? _safeZoom(widget.zoom) : currentZoom;
        _lastMovedCenter = widget.center;
        _lastMovedZoom = targetZoom;
        _lastMovedRotation = widget.rotation;
        _lastCameraMoveAt = DateTime.now();
        _mapController.moveAndRotate(
          widget.center,
          targetZoom,
          widget.rotation,
        );
      });
    }
  }

  @override
  void dispose() {
    _boundsDebounce?.cancel();
    super.dispose();
  }

  void refreshLayers() => _loadLayers();

  MapController get mapController => _mapController;

  String? _currentBounds() {
    final bounds = _mapController.bounds;
    if (bounds == null) return null;
    return '${bounds.south},${bounds.west},${bounds.north},${bounds.east}';
  }

  void _notifyBounds() {
    final bounds = _currentBounds();
    if (bounds != null) {
      widget.onBoundsChanged?.call(bounds);
    }
  }

  void _scheduleLayerReload({bool notifyBounds = false}) {
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 500), () {
      if (notifyBounds) _notifyBounds();
      _loadLayers();
    });
  }

  Future<void> _loadLayers() async {
    final layers = widget.layers;
    final needsData = layers.showCommunityObstacles ||
        layers.showInfrastructureIa ||
        layers.showGraphCoverage;
    if (!needsData) return;

    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) return;

    final bounds = _currentBounds();
    if (mounted) setState(() => _loadingLayers = true);

    try {
      final futures = <Future<void>>[];

      if (layers.showCommunityObstacles && _shouldLoadObstacles()) {
        futures.add(_loadObstacles(token, bounds));
      } else if (!layers.showCommunityObstacles) {
        _obstacles = const [];
      }

      if (layers.showInfrastructureIa && _shouldLoadInfra()) {
        futures.add(_loadInfra(token, bounds));
      } else if (!layers.showInfrastructureIa) {
        _infraPoints = const [];
      }

      if (layers.showGraphCoverage) {
        futures.add(_loadCoverage(token, bounds));
      } else {
        _coveragePoints = const [];
      }

      await Future.wait(futures);
    } finally {
      if (mounted) setState(() => _loadingLayers = false);
    }
  }

  bool _shouldLoadObstacles() {
    final filter = widget.moderationTypeFilter;
    return filter == null || filter == 'obstacles' || filter == 'all';
  }

  bool _shouldLoadInfra() {
    final filter = widget.moderationTypeFilter;
    return filter == null || filter == 'infra' || filter == 'all';
  }

  Future<void> _loadObstacles(String token, String? bounds) async {
    if (widget.mode == CycloMapMode.moderation) {
      final status = widget.moderationStatusFilter;
      final reports = await _reportsApi.getReportsForModeration(
        accessToken: token,
        bounds: bounds,
        status: status == 'all' ? null : status,
      );
      if (!mounted) return;
      setState(() {
        _obstacles = reports.where((r) => !r.isDismissed).toList();
      });
      return;
    }

    if (bounds == null) return;
    final parts = bounds.split(',');
    if (parts.length != 4) return;
    final south = double.tryParse(parts[0]) ?? 0;
    final west = double.tryParse(parts[1]) ?? 0;
    final north = double.tryParse(parts[2]) ?? 0;
    final east = double.tryParse(parts[3]) ?? 0;
    final centerLat = (south + north) / 2;
    final centerLng = (west + east) / 2;
    final radiusM = _boundsRadiusM(south, west, north, east);

    final reports = await _reportsApi.getNearbyReports(
      accessToken: token,
      lat: centerLat,
      lng: centerLng,
      radiusM: radiusM.round().clamp(200, 2500),
    );
    if (!mounted) return;
    setState(() {
      _obstacles = reports.where((r) => r.isActive).toList();
    });
  }

  Future<void> _loadInfra(String token, String? bounds) async {
    final status = widget.mode == CycloMapMode.user
        ? 'active'
        : widget.moderationStatusFilter == 'all'
        ? null
        : widget.moderationStatusFilter;

    final points = await _infraApi.getMapPoints(
      accessToken: token,
      bounds: bounds,
      status: status,
    );
    if (!mounted) return;
    setState(() {
      _infraPoints = points.where((p) => !p.isHidden).toList();
    });
  }

  Future<void> _loadCoverage(String token, String? bounds) async {
    final points = await _routeApi.getCoverage(
      accessToken: token,
      bounds: bounds,
    );
    if (!mounted) return;
    setState(() => _coveragePoints = points);
  }

  int _boundsRadiusM(double south, double west, double north, double east) {
    const earthRadiusM = 6371000.0;
    final centerLat = (south + north) / 2;
    final centerLng = (west + east) / 2;
    final corners = [
      LatLng(south, west),
      LatLng(south, east),
      LatLng(north, west),
      LatLng(north, east),
    ];
    var maxDist = 200.0;
    for (final corner in corners) {
      final dLat = _toRad(corner.latitude - centerLat);
      final dLng = _toRad(corner.longitude - centerLng);
      final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_toRad(centerLat)) *
              math.cos(_toRad(corner.latitude)) *
              math.sin(dLng / 2) *
              math.sin(dLng / 2);
      final dist = 2 * earthRadiusM * math.asin(math.sqrt(a));
      if (dist > maxDist) maxDist = dist;
    }
    return (maxDist + 180).round();
  }

  double _toRad(double deg) => deg * math.pi / 180.0;

  List<Marker> _layerMarkers() {
    final markers = <Marker>[];

    if (widget.layers.showGraphCoverage) {
      for (final point in _coveragePoints) {
        markers.add(
          Marker(
            point: LatLng(point.latitude, point.longitude),
            width: 18,
            height: 18,
            builder: (_) => Container(
              decoration: BoxDecoration(
                color: CycloMapStyles.coverageColor(point),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        );
      }
    }

    if (widget.layers.showInfrastructureIa) {
      for (final point in _infraPoints) {
        markers.add(
          Marker(
            point: LatLng(point.latitude, point.longitude),
            width: 28,
            height: 28,
            builder: (ctx) => GestureDetector(
              onTap: widget.onMarkerTap == null
                  ? null
                  : () => widget.onMarkerTap!(
                      CycloMapInfrastructureTap(point),
                    ),
              child: Container(
                decoration: CycloMapStyles.infrastructureDecoration(point),
              ),
            ),
          ),
        );
      }
    }

    if (widget.layers.showCommunityObstacles) {
      for (final report in _obstacles) {
        markers.add(
          Marker(
            point: LatLng(report.lat, report.lng),
            width: 28,
            height: 28,
            builder: (ctx) => GestureDetector(
              onTap: widget.onMarkerTap == null
                  ? null
                  : () => widget.onMarkerTap!(CycloMapObstacleTap(report)),
              child: Container(
                decoration: CycloMapStyles.obstacleDecoration(report),
              ),
            ),
          ),
        );
      }
    }

    if (widget.layers.showUserLocation && widget.userLocation != null) {
      markers.add(
        Marker(
          width: 46,
          height: 46,
          point: widget.userLocation!,
          builder: (_) => Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final allMarkers = [..._layerMarkers(), ...widget.extraMarkers];
    final showPolylines =
        widget.layers.showRoutes && widget.polylines.isNotEmpty;

    final map = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.center,
        zoom: _safeZoom(widget.zoom),
        minZoom: 3,
        maxZoom: CycloMap.maxDisplayZoom,
        rotation: widget.rotation,
        interactiveFlags: InteractiveFlag.all,
        onPositionChanged: (position, hasGesture) {
          widget.onPositionChanged?.call(position, hasGesture);
          if (hasGesture) {
            _scheduleLayerReload(notifyBounds: true);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.mapTileUrlTemplate,
          subdomains: AppConfig.mapTileSubdomains,
          userAgentPackageName: 'com.cycloroute.mobile',
          maxNativeZoom: CycloMap.maxTileZoom,
          maxZoom: CycloMap.maxDisplayZoom,
          keepBuffer: 5,
          panBuffer: 0,
          tileDisplay: const TileDisplay.instantaneous(),
          backgroundColor: AppColors.background,
        ),
        if (showPolylines) PolylineLayer(polylines: widget.polylines),
        if (allMarkers.isNotEmpty) MarkerLayer(markers: allMarkers),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              AppConfig.mapAttribution,
              textStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );

    final mapWidget = widget.borderRadius <= 0
        ? map
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: map,
          );

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          mapWidget,
          if (widget.showCenterPin)
            Center(
              child: Icon(
                widget.centerPinIcon,
                size: 42,
                color: widget.centerPinColor,
              ),
            ),
          if (widget.showLegend)
            Positioned(
              left: 12,
              bottom: 12,
              child: CycloMapLegend(layers: widget.layers, mode: widget.mode),
            ),
          if (_loadingLayers)
            const Positioned(
              top: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _shouldMoveMap(CycloMap oldWidget) {
    final lastCenter = _lastMovedCenter;
    final lastZoom = _lastMovedZoom;
    final lastRotation = _lastMovedRotation;

    if (lastCenter == null || lastZoom == null || lastRotation == null) {
      return true;
    }

    final movedEnough =
        const Distance().as(LengthUnit.Meter, lastCenter, widget.center) > 7.0;
    final rotationChanged =
        _rotationDelta(lastRotation, widget.rotation) > 7.0;
    final lastMoveAt = _lastCameraMoveAt;
    final cameraUpdateIsTooSoon =
        lastMoveAt != null &&
        DateTime.now().difference(lastMoveAt).inMilliseconds < 180;

    if (cameraUpdateIsTooSoon && !movedEnough) {
      return false;
    }

    return movedEnough || rotationChanged;
  }

  double _rotationDelta(double a, double b) {
    final delta = (b - a + 540) % 360 - 180;
    return delta.abs();
  }

  double _safeZoom(double zoom) {
    return zoom.clamp(3, CycloMap.maxDisplayZoom).toDouble();
  }
}
