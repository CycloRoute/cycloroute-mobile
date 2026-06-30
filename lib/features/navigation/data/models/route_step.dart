import 'package:cyclerisk/features/navigation/data/models/route_step_segment.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteStep {
  const RouteStep({
    required this.index,
    required this.type,
    required this.instruction,
    required this.name,
    required this.distanceM,
    required this.durationS,
    required this.bearingBefore,
    required this.bearingAfter,
    required this.location,
    this.segment,
  });

  final int index;
  final String type;
  final String instruction;
  final String name;
  final double distanceM;
  final int durationS;
  final double bearingBefore;
  final double bearingAfter;
  final GeoPoint location;
  final RouteStepSegment? segment;

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final rawSegment = json['segment'];
    return RouteStep(
      index: (json['index'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'continue',
      instruction: json['instruction']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distanceM: (json['distance_m'] as num? ?? 0).toDouble(),
      durationS: (json['duration_s'] as num? ?? 0).toInt(),
      bearingBefore: (json['bearing_before'] as num? ?? 0).toDouble(),
      bearingAfter: (json['bearing_after'] as num? ?? 0).toDouble(),
      location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
      segment: rawSegment is Map<String, dynamic>
          ? RouteStepSegment.fromJson(rawSegment)
          : null,
    );
  }
}
