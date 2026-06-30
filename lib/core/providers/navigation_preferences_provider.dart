import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/core/services/navigation_tts_service.dart';

class NavigationPreferencesProvider extends ChangeNotifier {
  static const _voiceEnabledKey = 'nav_voice_guidance_enabled';
  static const _voiceLanguageKey = 'nav_voice_language';
  static const _distanceUnitKey = 'nav_distance_unit';

  bool _voiceGuidanceEnabled = true;
  VoiceLanguageOption _voiceLanguage = VoiceLanguageOption.system;
  DistanceUnit _distanceUnit = DistanceUnit.kilometers;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  bool get voiceGuidanceEnabled => _voiceGuidanceEnabled;
  VoiceLanguageOption get voiceLanguage => _voiceLanguage;
  DistanceUnit get distanceUnit => _distanceUnit;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _voiceGuidanceEnabled = prefs.getBool(_voiceEnabledKey) ?? true;
    _voiceLanguage = VoiceLanguageOption.fromStorage(
      prefs.getString(_voiceLanguageKey),
    );
    _distanceUnit = DistanceUnit.fromStorage(prefs.getString(_distanceUnitKey));
    _initialized = true;
    notifyListeners();
  }

  Future<void> setVoiceGuidanceEnabled(bool enabled) async {
    if (_voiceGuidanceEnabled == enabled) {
      return;
    }

    _voiceGuidanceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setVoiceLanguage(VoiceLanguageOption option) async {
    if (_voiceLanguage == option) {
      return;
    }

    _voiceLanguage = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_voiceLanguageKey, option.storageValue);
    notifyListeners();
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    if (_distanceUnit == unit) {
      return;
    }

    _distanceUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distanceUnitKey, unit.storageValue);
    notifyListeners();
  }

  Future<void> applyFromServer({
    required bool voiceGuidanceEnabled,
    required VoiceLanguageOption voiceLanguage,
    required DistanceUnit distanceUnit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var changed = false;

    if (_voiceGuidanceEnabled != voiceGuidanceEnabled) {
      _voiceGuidanceEnabled = voiceGuidanceEnabled;
      await prefs.setBool(_voiceEnabledKey, voiceGuidanceEnabled);
      changed = true;
    }

    if (_voiceLanguage != voiceLanguage) {
      _voiceLanguage = voiceLanguage;
      await prefs.setString(_voiceLanguageKey, voiceLanguage.storageValue);
      changed = true;
    }

    if (_distanceUnit != distanceUnit) {
      _distanceUnit = distanceUnit;
      await prefs.setString(_distanceUnitKey, distanceUnit.storageValue);
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  String resolveTtsLanguageCode(String appLanguageCode) {
    final override = _voiceLanguage.languageCodeOrNull();
    return navigationTtsLanguageCode(override ?? appLanguageCode);
  }
}
