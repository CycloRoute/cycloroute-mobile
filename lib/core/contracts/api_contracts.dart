import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/auth/data/models/auth_session.dart';
import 'package:cyclerisk/features/auth/data/models/auth_user.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/features/route_search/data/models/place_suggestion.dart';
import 'package:cyclerisk/features/route_search/data/models/recent_place_item.dart';

abstract class AuthApiContract {
  Future<AuthSession> register({
    required String firstnames,
    required String lastnames,
    required String emailAddress,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  });

  Future<AuthSession> login({
    required String emailAddress,
    required String password,
  });

  Future<String> forgotPassword({required String emailAddress});

  Future<String> resetPassword({
    required String emailAddress,
    required String code,
    required String newPassword,
  });
}

abstract class UsersApiContract {
  Future<AuthUser> getMe({required String accessToken});

  Future<AuthUser> updateMe({
    required String accessToken,
    RoutePreference? defaultRoutePreference,
    BikeProfile? defaultBikeProfile,
    bool? voiceGuidanceEnabled,
    VoiceLanguageOption? voiceLanguage,
    DistanceUnit? distanceUnit,
  });

  Future<AuthUser> updateRoutePreference({
    required String accessToken,
    required RoutePreference preference,
  });
}

abstract class RecentPlacesApiContract {
  Future<List<RecentPlaceItem>> getRecent({
    required String accessToken,
    required String type,
    int limit,
  });

  Future<RecentPlaceUpsertResponse> upsert({
    required String accessToken,
    required Map<String, dynamic> body,
  });

  Future<int> deleteByType({
    required String accessToken,
    required String type,
  });
}

abstract class PlacesApiContract {
  Future<List<PlaceSuggestion>> search({
    required String accessToken,
    required String query,
    GeoPoint? near,
    int limit,
  });

  Future<PlaceSuggestion> reverse({
    required String accessToken,
    required GeoPoint point,
  });
}
