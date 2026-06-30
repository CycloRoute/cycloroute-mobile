import 'package:cyclerisk/features/navigation/data/models/route_step.dart';

class RouteLeg {
  const RouteLeg({
    required this.distanceM,
    required this.durationS,
    required this.steps,
  });

  final double distanceM;
  final int durationS;
  final List<RouteStep> steps;

  factory RouteLeg.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    return RouteLeg(
      distanceM: (json['distance_m'] as num? ?? 0).toDouble(),
      durationS: (json['duration_s'] as num? ?? 0).toInt(),
      steps: rawSteps is List
          ? rawSteps
                .whereType<Map<String, dynamic>>()
                .map(RouteStep.fromJson)
                .toList()
          : const [],
    );
  }
}
