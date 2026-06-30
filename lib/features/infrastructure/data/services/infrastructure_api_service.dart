import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';

class InfrastructureApiService {
  InfrastructureApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<InfrastructureAnalysisResult> analyze({
    required String accessToken,
    required Uint8List imageBytes,
    required String filename,
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
      files: [
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
          contentType: _mimeTypeForFilename(filename),
        ),
      ],
    );

    return InfrastructureAnalysisResult.fromJson(json);
  }

  MediaType _mimeTypeForFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lower.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    return MediaType('image', 'jpeg');
  }

  Future<List<InfrastructureMapPoint>> getMapPoints({
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

    final path = query.isEmpty
        ? '/infrastructure/map'
        : '/infrastructure/map';

    final decoded = await _apiClient.getRaw(
      path,
      accessToken: accessToken,
      queryParameters: query.isEmpty ? null : query,
    );

    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(InfrastructureMapPoint.fromJson)
        .toList();
  }

  Future<InfrastructureMapPoint> updateReportStatus({
    required String accessToken,
    required String reportId,
    required String status,
  }) async {
    final json = await _apiClient.patch(
      '/infrastructure/$reportId',
      accessToken: accessToken,
      body: {'status': status},
    );
    return InfrastructureMapPoint.fromJson(json);
  }

  Future<void> deleteReport({
    required String accessToken,
    required String reportId,
  }) async {
    await _apiClient.delete(
      '/infrastructure/$reportId',
      accessToken: accessToken,
    );
  }
}
