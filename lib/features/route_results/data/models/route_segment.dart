class RouteSegment {
  const RouteSegment({
    required this.fromIndex,
    required this.toIndex,
    required this.distanceM,
    required this.cycloScore,
    this.riskLevel,
    this.condition,
    this.infrastructureType,
    this.bikeInfrastructureCoverage,
  });

  final int fromIndex;
  final int toIndex;
  final double distanceM;
  final double cycloScore;
  final String? riskLevel;
  final String? condition;
  final String? infrastructureType;
  final double? bikeInfrastructureCoverage;

  factory RouteSegment.fromJson(Map<String, dynamic> json) {
    return RouteSegment(
      fromIndex: (json['from_index'] as num?)?.toInt() ?? 0,
      toIndex: (json['to_index'] as num?)?.toInt() ?? 0,
      distanceM: (json['distance_m'] as num? ?? 0).toDouble(),
      cycloScore: (json['cyclo_score'] as num? ?? 0).toDouble(),
      riskLevel: json['risk_level']?.toString(),
      condition: json['condition']?.toString(),
      infrastructureType: json['infrastructure_type']?.toString(),
      bikeInfrastructureCoverage:
          (json['bike_infrastructure_coverage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_index': fromIndex,
      'to_index': toIndex,
      'distance_m': distanceM,
      'cyclo_score': cycloScore,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (condition != null) 'condition': condition,
      if (infrastructureType != null)
        'infrastructure_type': infrastructureType,
      if (bikeInfrastructureCoverage != null)
        'bike_infrastructure_coverage': bikeInfrastructureCoverage,
    };
  }
}
