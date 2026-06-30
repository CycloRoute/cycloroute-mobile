import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';

class ReportsApiService {
  ReportsApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<ObstacleReport> createReport({
    required String accessToken,
    required double lat,
    required double lng,
    required String description,
    required ObstacleCategory category,
    required ObstacleSeverity severity,
    String type = 'obstacle',
  }) async {
    final json = await _apiClient.post(
      '/reports',
      accessToken: accessToken,
      body: {
        'lat': lat,
        'lng': lng,
        'type': type,
        'description': description,
        'category': category.apiValue,
        'severity': severity.apiValue,
      },
    );

    return ObstacleReport.fromJson(json);
  }

  Future<List<ObstacleReport>> getMyReports({
    required String accessToken,
  }) async {
    final decoded = await _apiClient.getRaw(
      '/reports/mine',
      accessToken: accessToken,
    );
    return _parseList(decoded);
  }

  Future<List<ObstacleReport>> getNearbyReports({
    required String accessToken,
    required double lat,
    required double lng,
    required int radiusM,
  }) async {
    final decoded = await _apiClient.getRaw(
      '/reports/nearby?lat=$lat&lng=$lng&radius_m=$radiusM',
      accessToken: accessToken,
    );
    return _parseList(decoded);
  }

  Future<List<ObstacleReport>> getReports({
    required String accessToken,
    String? bounds,
    String? status,
  }) async {
    final query = <String, String>{};
    if (bounds != null && bounds.isNotEmpty) {
      query['bounds'] = bounds;
    }
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final decoded = await _apiClient.getRaw(
      '/reports',
      accessToken: accessToken,
      queryParameters: query.isEmpty ? null : query,
    );
    return _parseList(decoded);
  }

  Future<List<ObstacleReport>> getReportsForModeration({
    required String accessToken,
    String? bounds,
    String? status,
  }) {
    return getReports(
      accessToken: accessToken,
      bounds: bounds,
      status: status,
    );
  }

  Future<ObstacleReport> updateReport({
    required String accessToken,
    required String reportId,
    String? status,
    String? description,
    ObstacleCategory? category,
    ObstacleSeverity? severity,
    DateTime? expiresAt,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category.apiValue;
    if (severity != null) body['severity'] = severity.apiValue;
    if (expiresAt != null) {
      body['expires_at'] = expiresAt.toUtc().toIso8601String();
    }

    final json = await _apiClient.patch(
      '/reports/$reportId',
      accessToken: accessToken,
      body: body,
    );
    return ObstacleReport.fromJson(json);
  }

  Future<ObstacleReport> updateReportStatus({
    required String accessToken,
    required String reportId,
    required String status,
    DateTime? expiresAt,
  }) {
    return updateReport(
      accessToken: accessToken,
      reportId: reportId,
      status: status,
      expiresAt: expiresAt,
    );
  }

  Future<void> deleteReport({
    required String accessToken,
    required String reportId,
  }) async {
    await _apiClient.delete(
      '/reports/$reportId',
      accessToken: accessToken,
    );
  }

  List<ObstacleReport> _parseList(dynamic decoded) {
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ObstacleReport.fromJson)
        .toList();
  }
}
