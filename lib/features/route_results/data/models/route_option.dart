import 'package:cyclerisk/features/navigation/data/models/route_leg.dart';
import 'package:cyclerisk/features/navigation/data/models/route_step.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_results/data/models/route_segment.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteOption {
  const RouteOption({
    required this.routeId,
    required this.distanceM,
    required this.cycloScore,
    required this.coordinates,
    this.label,
    this.condition,
    this.durationMin,
    this.riskLevel,
    this.why = const [],
    this.legs = const [],
    this.segments,
    this.alertsAlongRoute,
    this.rawPayload = const <String, dynamic>{},
  });

  final String routeId;
  final double distanceM;
  final double cycloScore;
  final List<GeoPoint> coordinates;
  final String? label;
  final String? condition;
  final double? durationMin;
  final String? riskLevel;
  final List<String> why;
  final List<RouteLeg> legs;
  final List<RouteSegment>? segments;
  final List<RiskAlert>? alertsAlongRoute;
  final Map<String, dynamic> rawPayload;

  RouteLeg? get leg => legs.isNotEmpty ? legs.first : null;
  List<RouteStep> get steps => leg?.steps ?? const [];

  String get name => label?.trim().isNotEmpty == true ? label! : routeId;
  double get distanceKm => distanceM / 1000;
  int get durationRounded => (durationMin ?? (distanceKm / 15 * 60)).round();
  double get fitScore => (cycloScore * 100).clamp(0, 100);
  double get safetyScore =>
      (_readNestedDouble('summary', 'average_safety_score') ??
              _readDouble('safety_score') ??
              cycloScore)
          .clamp(0, 1);
  double get bikeInfrastructureCoverage =>
      (_readNestedDouble('summary', 'bike_infrastructure_coverage') ??
              _readDouble('bike_infrastructure_coverage') ??
              0)
          .clamp(0, 1);
  double get streetviewScoredCoverage =>
      (_readNestedDouble('summary', 'streetview_scored_coverage') ??
              _readDouble('streetview_scored_coverage') ??
              0)
          .clamp(0, 1);
  double get extraDistancePct => _readDouble('extra_distance_pct') ?? 0;

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final coordinates = json['coordinates'] is List
        ? (json['coordinates'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(GeoPoint.fromJson)
              .toList()
        : const <GeoPoint>[];
    final legs = json['legs'] is List
        ? (json['legs'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(RouteLeg.fromJson)
              .toList()
        : const <RouteLeg>[];
    final segments = json['segments'] is List
        ? (json['segments'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(RouteSegment.fromJson)
              .toList()
        : null;
    final alertsAlongRoute = json['alerts_along_route'] is List
        ? (json['alerts_along_route'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(RiskAlert.fromJson)
              .toList()
        : null;

    return RouteOption(
      routeId: json['route_id']?.toString() ?? 'route',
      distanceM: (json['distance_m'] as num? ?? 0).toDouble(),
      cycloScore: (json['cyclo_score'] as num? ?? 0).toDouble(),
      coordinates: coordinates,
      label: json['label']?.toString(),
      condition: json['condition']?.toString(),
      durationMin: (json['duration_min'] as num?)?.toDouble(),
      riskLevel: summary['risk_level']?.toString(),
      why: json['why'] is List
          ? (json['why'] as List<dynamic>)
                .map((item) => item.toString())
                .toList()
          : const [],
      legs: legs,
      segments: segments,
      alertsAlongRoute: alertsAlongRoute,
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...rawPayload,
      'route_id': routeId,
      'distance_m': distanceM,
      'cyclo_score': cycloScore,
      'coordinates': coordinates.map((point) => point.toJson()).toList(),
      if (label != null) 'label': label,
      if (condition != null) 'condition': condition,
      if (durationMin != null) 'duration_min': durationMin,
      if (segments != null)
        'segments': segments!.map((segment) => segment.toJson()).toList(),
      if (alertsAlongRoute != null)
        'alerts_along_route':
            alertsAlongRoute!.map((alert) => alert.toJson()).toList(),
    };
  }

  double? _readDouble(String key) {
    final value = rawPayload[key];
    return value is num ? value.toDouble() : double.tryParse('$value');
  }

  double? _readNestedDouble(String parentKey, String key) {
    final parent = rawPayload[parentKey];
    if (parent is! Map<String, dynamic>) {
      return null;
    }

    final value = parent[key];
    return value is num ? value.toDouble() : double.tryParse('$value');
  }
}
