class InfrastructureDetection {
  const InfrastructureDetection({
    required this.className,
    required this.confidence,
  });

  final String className;
  final double confidence;

  factory InfrastructureDetection.fromJson(Map<String, dynamic> json) {
    return InfrastructureDetection(
      className: json['class']?.toString() ?? '',
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
    );
  }
}

class InfrastructureGraphUpdate {
  const InfrastructureGraphUpdate({
    required this.applied,
    required this.edgesUpdated,
    required this.radiusM,
    required this.nearestEdgeDistanceM,
  });

  final bool applied;
  final int edgesUpdated;
  final double radiusM;
  final double nearestEdgeDistanceM;

  factory InfrastructureGraphUpdate.fromJson(Map<String, dynamic> json) {
    return InfrastructureGraphUpdate(
      applied: json['applied'] == true,
      edgesUpdated: (json['edges_updated'] as num? ?? 0).toInt(),
      radiusM: (json['radius_m'] as num? ?? 0).toDouble(),
      nearestEdgeDistanceM: (json['nearest_edge_distance_m'] as num? ?? 0)
          .toDouble(),
    );
  }
}

class InfrastructureAnalysisResult {
  const InfrastructureAnalysisResult({
    required this.id,
    required this.score,
    required this.quality,
    required this.latitude,
    required this.longitude,
    required this.detections,
    required this.imageUrl,
    required this.graphUpdate,
    required this.createdAt,
  });

  final String id;
  final int score;
  final String quality;
  final double latitude;
  final double longitude;
  final List<InfrastructureDetection> detections;
  final String imageUrl;
  final InfrastructureGraphUpdate graphUpdate;
  final DateTime? createdAt;

  factory InfrastructureAnalysisResult.fromJson(Map<String, dynamic> json) {
    return InfrastructureAnalysisResult(
      id: json['id']?.toString() ?? '',
      score: (json['score'] as num? ?? 0).round(),
      quality: json['quality']?.toString() ?? 'REGULAR',
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      detections: json['detections'] is List
          ? (json['detections'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map(InfrastructureDetection.fromJson)
                .toList()
          : const [],
      imageUrl: json['image_url']?.toString() ?? '',
      graphUpdate: json['graph_update'] is Map<String, dynamic>
          ? InfrastructureGraphUpdate.fromJson(
              json['graph_update'] as Map<String, dynamic>,
            )
          : const InfrastructureGraphUpdate(
              applied: false,
              edgesUpdated: 0,
              radiusM: 0,
              nearestEdgeDistanceM: 0,
            ),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

class InfrastructureMapPoint {
  const InfrastructureMapPoint({
    required this.latitude,
    required this.longitude,
    required this.score,
    required this.quality,
  });

  final double latitude;
  final double longitude;
  final int score;
  final String quality;

  factory InfrastructureMapPoint.fromJson(Map<String, dynamic> json) {
    return InfrastructureMapPoint(
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      score: (json['score'] as num? ?? 0).round(),
      quality: json['quality']?.toString() ?? 'REGULAR',
    );
  }
}
