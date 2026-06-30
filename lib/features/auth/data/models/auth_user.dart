import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/auth/data/models/user_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstnames,
    required this.lastnames,
    required this.name,
    required this.emailAddress,
    required this.role,
    required this.defaultRoutePreference,
    required this.defaultBikeProfile,
    required this.voiceGuidanceEnabled,
    required this.voiceLanguage,
    required this.distanceUnit,
    this.phoneNumber,
    this.createdAt,
  });

  final String id;
  final String firstnames;
  final String lastnames;
  final String name;
  final String emailAddress;
  final String? phoneNumber;
  final UserRole role;
  final RoutePreference defaultRoutePreference;
  final BikeProfile defaultBikeProfile;
  final bool voiceGuidanceEnabled;
  final VoiceLanguageOption voiceLanguage;
  final DistanceUnit distanceUnit;
  final DateTime? createdAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      firstnames: json['firstnames']?.toString() ?? '',
      lastnames: json['lastnames']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      emailAddress: json['email_address']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      role: UserRole.fromApi(json['role']?.toString()),
      defaultRoutePreference: RoutePreference.fromApi(
        json['default_route_preference']?.toString(),
      ),
      defaultBikeProfile: BikeProfile.fromApi(
        json['default_bike_profile']?.toString(),
      ),
      voiceGuidanceEnabled: json['voice_guidance_enabled'] is bool
          ? json['voice_guidance_enabled'] as bool
          : true,
      voiceLanguage: VoiceLanguageOption.fromApi(
        json['voice_language']?.toString(),
      ),
      distanceUnit: DistanceUnit.fromApi(json['distance_unit']?.toString()),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstnames': firstnames,
      'lastnames': lastnames,
      'name': name,
      'email_address': emailAddress,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'role': role.apiValue,
      'default_route_preference': defaultRoutePreference.apiValue,
      'default_bike_profile': defaultBikeProfile.apiValue,
      'voice_guidance_enabled': voiceGuidanceEnabled,
      'voice_language': voiceLanguage.apiValue,
      'distance_unit': distanceUnit.apiValue,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
