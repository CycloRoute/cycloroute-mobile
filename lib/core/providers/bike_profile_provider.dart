import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';

class BikeProfileProvider extends ChangeNotifier {
  static const _storageKey = 'bike_profile';

  BikeProfile _profile = BikeProfile.urban;
  bool _initialized = false;

  BikeProfile get profile => _profile;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _profile = BikeProfile.fromApi(prefs.getString(_storageKey));
    _initialized = true;
    notifyListeners();
  }

  Future<void> setProfile(BikeProfile profile) async {
    if (_profile == profile) {
      return;
    }

    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, profile.apiValue);
    notifyListeners();
  }

  Future<void> applyFromServer(BikeProfile profile) async {
    if (_profile == profile) {
      return;
    }

    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, profile.apiValue);
    notifyListeners();
  }
}
