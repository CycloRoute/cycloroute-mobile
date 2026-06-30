import 'package:flutter_test/flutter_test.dart';
import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/features/auth/data/models/auth_user.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';

void main() {
  test('AuthUser parses navigation preferences from /users/me payload', () {
    final user = AuthUser.fromJson({
      'id': 'user-1',
      'firstnames': 'Ana',
      'lastnames': 'Lopez',
      'name': 'Ana Lopez',
      'email_address': 'ana@example.com',
      'role': 'user',
      'default_route_preference': 'balanced',
      'default_bike_profile': 'electric',
      'voice_guidance_enabled': false,
      'voice_language': 'english',
      'distance_unit': 'miles',
    });

    expect(user.defaultRoutePreference, RoutePreference.balanced);
    expect(user.defaultBikeProfile, BikeProfile.electric);
    expect(user.voiceGuidanceEnabled, isFalse);
    expect(user.voiceLanguage, VoiceLanguageOption.english);
    expect(user.distanceUnit, DistanceUnit.miles);
  });

  test('AuthUser falls back to defaults when preference fields are missing', () {
    final user = AuthUser.fromJson({
      'id': 'user-1',
      'firstnames': 'Ana',
      'lastnames': 'Lopez',
      'name': 'Ana Lopez',
      'email_address': 'ana@example.com',
      'role': 'user',
      'default_route_preference': 'recommended',
    });

    expect(user.defaultBikeProfile, BikeProfile.urban);
    expect(user.voiceGuidanceEnabled, isTrue);
    expect(user.voiceLanguage, VoiceLanguageOption.system);
    expect(user.distanceUnit, DistanceUnit.kilometers);
  });
}
