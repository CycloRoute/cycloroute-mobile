import 'package:cyclerisk/core/contracts/api_contracts.dart';
import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/route_search/data/models/recent_place_item.dart';

class RecentPlacesApiService implements RecentPlacesApiContract {
  RecentPlacesApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<List<RecentPlaceItem>> getRecent({
    required String accessToken,
    required String type,
    int limit = 5,
  }) async {
    final json = await _apiClient.get(
      '/users/me/recent-places',
      accessToken: accessToken,
      queryParameters: {
        'type': type,
        'limit': limit.clamp(1, 5).toString(),
      },
    );

    final rawItems = json['items'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(RecentPlaceItem.fromJson)
        .toList();
  }

  Future<RecentPlaceUpsertResponse> upsert({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _apiClient.post(
      '/users/me/recent-places',
      accessToken: accessToken,
      body: body,
    );

    return RecentPlaceUpsertResponse.fromJson(json);
  }

  Future<int> deleteByType({
    required String accessToken,
    required String type,
  }) async {
    final json = await _apiClient.delete(
      '/users/me/recent-places',
      accessToken: accessToken,
      queryParameters: {'type': type},
    );

    return (json['deleted'] as num?)?.toInt() ?? 0;
  }
}
