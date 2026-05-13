import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OsmMapWidget extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;

  OsmMapWidget({
    Key? key,
    LatLng? center,
    this.zoom = 13,
    this.markers = const [],
    this.polylines = const [],
  })  : center = center ?? LatLng(51.5074, -0.1278),
        super(key: key);

  @override
  State<OsmMapWidget> createState() => _OsmMapWidgetState();
}

class _OsmMapWidgetState extends State<OsmMapWidget> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant OsmMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameLocation(oldWidget.center, widget.center)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(widget.center, widget.zoom);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: widget.center,
            zoom: widget.zoom,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.cyclerisk',
            ),
            if (widget.polylines.isNotEmpty)
              PolylineLayer(polylines: widget.polylines),
            if (widget.markers.isNotEmpty) MarkerLayer(markers: widget.markers),
          ],
        ),
      ),
    );
  }

  bool _sameLocation(LatLng a, LatLng b) {
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }
}
