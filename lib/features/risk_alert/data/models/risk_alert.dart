class RiskAlert {
  const RiskAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.segmentIndex,
    this.distanceFromRouteStartM,
    this.segmentLengthM,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String recommendation;
  final String severity;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int? segmentIndex;
  final double? distanceFromRouteStartM;
  final double? segmentLengthM;

  factory RiskAlert.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return RiskAlert(
      id: (json['id'] ?? json['alert_id'] ?? '').toString(),
      type: (json['type'] ?? json['alert_type'] ?? 'road_risk').toString(),
      title: (json['title'] ?? json['name'] ?? 'Road risk alert').toString(),
      message: (json['message'] ?? json['description'] ?? json['details'] ?? '')
          .toString(),
      recommendation:
          (json['recommendation'] ??
                  json['advice'] ??
                  'Reduce speed and stay alert')
              .toString(),
      severity: (json['severity'] ?? json['risk_level'] ?? 'medium').toString(),
      latitude: _readDouble(json['lat'] ?? json['latitude'] ?? location['lat']),
      longitude: _readDouble(
        json['lng'] ?? json['lon'] ?? json['longitude'] ?? location['lng'],
      ),
      timestamp:
          DateTime.tryParse(
            (json['timestamp'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      segmentIndex: (json['segment_index'] as num?)?.toInt(),
      distanceFromRouteStartM:
          (json['distance_from_route_start_m'] as num?)?.toDouble(),
      segmentLengthM: (json['segment_length_m'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'recommendation': recommendation,
      'severity': severity,
      'location': {'lat': latitude, 'lng': longitude},
      if (segmentIndex != null) 'segment_index': segmentIndex,
      if (distanceFromRouteStartM != null)
        'distance_from_route_start_m': distanceFromRouteStartM,
      if (segmentLengthM != null) 'segment_length_m': segmentLengthM,
    };
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
