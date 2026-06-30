import 'package:cyclerisk/core/contracts/api_contracts.dart';
import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/auth/data/models/auth_user.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';

class UsersApiService implements UsersApiContract {
  UsersApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<AuthUser> getMe({required String accessToken}) async {
    final json = await _apiClient.get('/users/me', accessToken: accessToken);
    return AuthUser.fromJson(json);
  }

  Future<AuthUser> updateMe({
    required String accessToken,
    RoutePreference? defaultRoutePreference,
    BikeProfile? defaultBikeProfile,
    bool? voiceGuidanceEnabled,
    VoiceLanguageOption? voiceLanguage,
    DistanceUnit? distanceUnit,
  }) async {
    final body = <String, dynamic>{};
    if (defaultRoutePreference != null) {
      body['default_route_preference'] = defaultRoutePreference.apiValue;
    }
    if (defaultBikeProfile != null) {
      body['default_bike_profile'] = defaultBikeProfile.apiValue;
    }
    if (voiceGuidanceEnabled != null) {
      body['voice_guidance_enabled'] = voiceGuidanceEnabled;
    }
    if (voiceLanguage != null) {
      body['voice_language'] = voiceLanguage.apiValue;
    }
    if (distanceUnit != null) {
      body['distance_unit'] = distanceUnit.apiValue;
    }

    final json = await _apiClient.patch(
      '/users/me',
      accessToken: accessToken,
      body: body,
    );

    return AuthUser.fromJson(json);
  }

  Future<AuthUser> updateRoutePreference({
    required String accessToken,
    required RoutePreference preference,
  }) {
    return updateMe(
      accessToken: accessToken,
      defaultRoutePreference: preference,
    );
  }
}
