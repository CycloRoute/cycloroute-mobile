import 'package:http/http.dart' as http;

import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';

class InfrastructureApiService {
  InfrastructureApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<InfrastructureAnalysisResult> analyze({
    required String accessToken,
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    final json = await _apiClient.postMultipart(
      '/infrastructure/analyze',
      accessToken: accessToken,
      fields: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
      files: [await http.MultipartFile.fromPath('image', imagePath)],
    );

    return InfrastructureAnalysisResult.fromJson(json);
  }

  Future<List<InfrastructureMapPoint>> getMapPoints({
    required String accessToken,
    String? bounds,
  }) async {
    final path = bounds == null || bounds.isEmpty
        ? '/infrastructure/map'
        : '/infrastructure/map?bounds=$bounds';

    final decoded = await _apiClient.getRaw(path, accessToken: accessToken);

    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(InfrastructureMapPoint.fromJson)
        .toList();
  }
}
