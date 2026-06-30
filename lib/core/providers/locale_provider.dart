import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _localeKey = 'app_locale_code';

  Locale? _overrideLocale;
  bool _isInitialized = false;

  Locale? get overrideLocale => _overrideLocale;
  bool get isInitialized => _isInitialized;

  /// `null` means follow the device language.
  Locale? get effectiveLocale => _overrideLocale;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    _overrideLocale = _localeFromCode(code);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
      _overrideLocale = null;
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
      _overrideLocale = locale;
    }
    notifyListeners();
  }

  Locale? _localeFromCode(String? code) {
    if (code == null || code.isEmpty) {
      return null;
    }
    if (code == 'es') {
      return const Locale('es');
    }
    return const Locale('en');
  }
}
