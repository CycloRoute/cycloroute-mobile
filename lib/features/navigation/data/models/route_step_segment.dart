class RouteStepSegment {
  const RouteStepSegment({
    required this.cycloScore,
    this.riskLevel,
    this.condition,
    this.infrastructureType,
    this.bikeInfrastructureCoverage,
  });

  final double cycloScore;
  final String? riskLevel;
  final String? condition;
  final String? infrastructureType;
  final double? bikeInfrastructureCoverage;

  factory RouteStepSegment.fromJson(Map<String, dynamic> json) {
    return RouteStepSegment(
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
