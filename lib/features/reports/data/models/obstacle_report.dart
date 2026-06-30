import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';

class ObstacleReport {
  const ObstacleReport({
    required this.id,
    required this.lat,
    required this.lng,
    required this.type,
    required this.description,
    this.category = ObstacleCategory.other,
    this.severity = ObstacleSeverity.medium,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.reporterName,
  });

  final String id;
  final double lat;
  final double lng;
  final String type;
  final String description;
  final ObstacleCategory category;
  final ObstacleSeverity severity;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? reporterName;

  bool get isActive {
    final normalized = status?.toLowerCase();
    return normalized == null || normalized == 'active';
  }

  bool get isPending => status?.toLowerCase() == 'pending';

  bool get isDismissed {
    final normalized = status?.toLowerCase();
    return normalized == 'dismissed' || normalized == 'hidden';
  }

  factory ObstacleReport.fromJson(Map<String, dynamic> json) {
    return ObstacleReport(
      id: json['id']?.toString() ?? '',
      lat: (json['lat'] as num? ?? 0).toDouble(),
      lng: (json['lng'] as num? ?? 0).toDouble(),
      type: json['type']?.toString() ?? 'obstacle',
      description: json['description']?.toString() ?? '',
      category: ObstacleCategory.fromApi(json['category']?.toString()),
      severity: ObstacleSeverity.fromApi(json['severity']?.toString()),
      status: json['status']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.tryParse(json['expires_at'].toString()),
      reporterName: json['reporter_name']?.toString() ??
          json['user_name']?.toString(),
    );
  }
}
