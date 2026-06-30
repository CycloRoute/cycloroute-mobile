import 'package:cyclerisk/features/navigation/data/models/engine_meta.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

/// Result of POST /routes/map-match (backend → engine).
typedef MapMatchResult = MapMatchResponse;

class MapMatchResponse {  const MapMatchResponse({
    required this.input,
    required this.snappedPoint,
    required this.distanceFromInputM,
    required this.snappedNodeId,
    required this.engineMeta,
  });

  final GeoPoint input;
  final GeoPoint snappedPoint;
  final double distanceFromInputM;
  /// Debug only — may be int, string, or coordinate tuple from engine.
  final String snappedNodeId;  final EngineMeta engineMeta;

  factory MapMatchResponse.fromJson(Map<String, dynamic> json) {
    return MapMatchResponse(
      input: GeoPoint.fromJson(json['input'] as Map<String, dynamic>),
      snappedPoint: GeoPoint.fromJson(
        json['snapped_point'] as Map<String, dynamic>,
      ),
      distanceFromInputM:
          (json['distance_from_input_m'] as num? ?? 0).toDouble(),
      snappedNodeId: json['snapped_node_id']?.toString() ?? '',
      engineMeta: EngineMeta.fromJson(
        json['engine_meta'] as Map<String, dynamic>?,
      ),
    );
  }
}
