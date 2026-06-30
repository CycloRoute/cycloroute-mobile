import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_session.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class NavigationCacheData {
  const NavigationCacheData({
    required this.session,
    required this.activeRoute,
    required this.preference,
    required this.destination,
    this.bikeProfile = BikeProfile.urban,
    this.origin,
    this.originLabel,
    this.destinationLabel,
    this.currentStepIndex = 0,
  });

  final NavigationSession session;
  final RouteOption activeRoute;
  final RoutePreference preference;
  final BikeProfile bikeProfile;
  final GeoPoint destination;
  final GeoPoint? origin;
  final String? originLabel;
  final String? destinationLabel;
  final int currentStepIndex;

  Map<String, dynamic> toJson() {
    return {
      'session': session.toJson(),
      'active_route': activeRoute.toJson(),
      'preference': preference.apiValue,
      'bike_profile': bikeProfile.apiValue,
      'destination': destination.toJson(),
      if (origin != null) 'origin': origin!.toJson(),
      'origin_label': originLabel,
      'destination_label': destinationLabel,
      'current_step_index': currentStepIndex,
    };
  }

  factory NavigationCacheData.fromJson(Map<String, dynamic> json) {
    return NavigationCacheData(
      session: NavigationSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      activeRoute: RouteOption.fromJson(
        json['active_route'] as Map<String, dynamic>,
      ),
      preference: RoutePreference.fromApi(json['preference']?.toString()),
      bikeProfile: BikeProfile.fromApi(json['bike_profile']?.toString()),
      destination: GeoPoint.fromJson(json['destination'] as Map<String, dynamic>),
      origin: json['origin'] is Map<String, dynamic>
          ? GeoPoint.fromJson(json['origin'] as Map<String, dynamic>)
          : null,
      originLabel: json['origin_label']?.toString(),
      destinationLabel: json['destination_label']?.toString(),
      currentStepIndex: (json['current_step_index'] as num?)?.toInt() ?? 0,
    );
  }
}

class NavigationCacheRepository {
  static const _cacheKey = 'active_navigation_cache_v1';

  Future<void> save(NavigationCacheData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
  }

  Future<NavigationCacheData?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return NavigationCacheData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
