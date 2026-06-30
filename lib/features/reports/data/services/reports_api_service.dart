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
  }) async {
    final decoded = await _apiClient.getRaw('/reports', accessToken: accessToken);
    return _parseList(decoded);
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
