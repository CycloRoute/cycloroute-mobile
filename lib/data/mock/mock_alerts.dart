class RiskAlert {
  final String id;
  final String
  type; // e.g., 'high_traffic', 'intersection', 'poor_infrastructure'
  final String title;
  final String message;
  final String recommendation;
  final String severity; // 'low', 'medium', 'high'
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  RiskAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

class MockAlerts {
  static List<RiskAlert> getAllAlerts() {
    return [
      RiskAlert(
        id: 'alert_1',
        type: 'high_traffic_intersection',
        title: 'High traffic intersection',
        message:
            'Heavy vehicle traffic detected at this intersection during rush hours.',
        recommendation: 'Reduce speed and stay alert',
        severity: 'high',
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
      ),
      RiskAlert(
        id: 'alert_2',
        type: 'poor_infrastructure',
        title: 'Limited bike lane',
        message:
            'This segment has no dedicated bike lane. Share the road carefully.',
        recommendation: 'Use hand signals and stay visible',
        severity: 'medium',
        latitude: 40.7132,
        longitude: -74.0070,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      RiskAlert(
        id: 'alert_3',
        type: 'construction',
        title: 'Road construction',
        message:
            'Active road construction with temporary traffic patterns in this zone.',
        recommendation: 'Follow temporary bike lane markers',
        severity: 'medium',
        latitude: 40.7135,
        longitude: -74.0075,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      RiskAlert(
        id: 'alert_4',
        type: 'high_traffic',
        title: 'Heavy traffic area',
        message: 'Above-average traffic volume on this road segment.',
        recommendation:
            'Consider alternative route or wait for traffic to decrease',
        severity: 'medium',
        latitude: 40.7140,
        longitude: -74.0065,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RiskAlert(
        id: 'alert_5',
        type: 'steep_slope',
        title: 'Steep downhill section',
        message:
            'This segment has a significant elevation drop. Brakes may overheat.',
        recommendation: 'Reduce speed and use both brakes evenly',
        severity: 'high',
        latitude: 40.7145,
        longitude: -74.0080,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  static RiskAlert getActiveAlert() {
    return RiskAlert(
      id: 'alert_active',
      type: 'high_traffic_intersection',
      title: 'High traffic intersection',
      message:
          'Heavy vehicle traffic detected at Fifth Avenue. Peak hours traffic pattern.',
      recommendation: 'Reduce speed and stay alert',
      severity: 'high',
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
    );
  }

  static List<RiskAlert> getNearbyAlerts() {
    return [getAllAlerts()[0], getAllAlerts()[1]];
  }
}
