import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _apiBaseUrlDefine = String.fromEnvironment(
    'CYCLO_ROUTE_API_BASE_URL',
    defaultValue: '',
  );

  static const String _mapTilerApiKeyDefine = String.fromEnvironment(
    'MAPTILER_API_KEY',
    defaultValue: '',
  );

  static const String _mapTilerStyleDefine = String.fromEnvironment(
    'MAPTILER_STYLE',
    defaultValue: '',
  );

  static String get apiBaseUrl => _apiBaseUrlDefine.trim().isNotEmpty
      ? _apiBaseUrlDefine
      : _env('CYCLO_ROUTE_API_BASE_URL', 'http://localhost:3000');

  static String get mapTilerApiKey => _mapTilerApiKeyDefine.trim().isNotEmpty
      ? _mapTilerApiKeyDefine
      : _env('MAPTILER_API_KEY', '');

  static String get mapTilerStyle => _mapTilerStyleDefine.trim().isNotEmpty
      ? _mapTilerStyleDefine
      : _env('MAPTILER_STYLE', 'streets-v2');

  static bool get hasMapTilerKey => mapTilerApiKey.trim().isNotEmpty;

  static String get mapTileUrlTemplate {
    if (hasMapTilerKey) {
      return 'https://api.maptiler.com/maps/$mapTilerStyle/256/{z}/{x}/{y}.png?key=$mapTilerApiKey';
    }

    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  static List<String> get mapTileSubdomains {
    return hasMapTilerKey ? const [] : const ['a', 'b', 'c'];
  }

  static String get mapAttribution {
    return hasMapTilerKey
        ? 'MapTiler - OpenStreetMap contributors'
        : 'OpenStreetMap contributors';
  }

  static String _env(String key, String fallback) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
