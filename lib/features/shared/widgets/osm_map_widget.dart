import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/core/config/app_config.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';

class OsmMapWidget extends StatefulWidget {
  static const double maxDisplayZoom = 20;
  static const int maxTileZoom = 18;

  final LatLng center;
  final double zoom;
  final double height;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final double rotation;
  final double borderRadius;

  OsmMapWidget({
    Key? key,
    LatLng? center,
    this.zoom = 13,
    this.height = 280,
    this.markers = const [],
    this.polylines = const [],
    this.rotation = 0,
    this.borderRadius = 12,
  }) : center = center ?? LatLng(51.5074, -0.1278),
       super(key: key);

  @override
  State<OsmMapWidget> createState() => _OsmMapWidgetState();
}

class _OsmMapWidgetState extends State<OsmMapWidget> {
  final MapController _mapController = MapController();
  LatLng? _lastMovedCenter;
  double? _lastMovedZoom;
  double? _lastMovedRotation;
  DateTime? _lastCameraMoveAt;

  @override
  void didUpdateWidget(covariant OsmMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldMoveMap()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentZoom = _safeZoom(_mapController.zoom);
        final targetZoom = oldWidget.zoom == widget.zoom
            ? currentZoom
            : _safeZoom(widget.zoom);
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
  Widget build(BuildContext context) {
    final map = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.center,
        zoom: _safeZoom(widget.zoom),
        minZoom: 3,
        maxZoom: OsmMapWidget.maxDisplayZoom,
        rotation: widget.rotation,
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.mapTileUrlTemplate,
          subdomains: AppConfig.mapTileSubdomains,
          userAgentPackageName: 'com.cycloroute.mobile',
          maxNativeZoom: OsmMapWidget.maxTileZoom,
          maxZoom: OsmMapWidget.maxDisplayZoom,
          keepBuffer: 5,
          panBuffer: 0,
          tileDisplay: const TileDisplay.instantaneous(),
          backgroundColor: AppColors.background,
        ),
        if (widget.polylines.isNotEmpty)
          PolylineLayer(polylines: widget.polylines),
        if (widget.markers.isNotEmpty) MarkerLayer(markers: widget.markers),
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

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: widget.borderRadius <= 0
          ? map
          : ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: map,
            ),
    );
  }

  bool _shouldMoveMap() {
    final lastCenter = _lastMovedCenter;
    final lastZoom = _lastMovedZoom;
    final lastRotation = _lastMovedRotation;

    if (lastCenter == null || lastZoom == null || lastRotation == null) {
      return true;
    }

    final movedEnough =
        const Distance().as(LengthUnit.Meter, lastCenter, widget.center) > 7.0;
    final rotationChanged = _rotationDelta(lastRotation, widget.rotation) > 7.0;
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
    return zoom.clamp(3, OsmMapWidget.maxDisplayZoom).toDouble();
  }
}
