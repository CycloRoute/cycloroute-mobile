import 'package:flutter_tts/flutter_tts.dart';

class NavigationTtsService {
  NavigationTtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  static const _minSpeakInterval = Duration(seconds: 4);

  final FlutterTts _tts;
  bool _initialized = false;
  String? _lastDedupeKey;
  DateTime? _lastSpeakAt;

  Future<void> initialize({required String languageCode}) async {
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> speakInstruction({
    required String text,
    required int stepIndex,
    bool force = false,
    String? dedupeKey,
  }) async {
    if (!_initialized) {
      return;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final key = dedupeKey ?? 'step:$stepIndex:$trimmed';
    final now = DateTime.now();

    if (!force) {
      if (_lastDedupeKey == key) {
        return;
      }
      if (_lastSpeakAt != null &&
          now.difference(_lastSpeakAt!) < _minSpeakInterval) {
        return;
      }
    }

    _lastDedupeKey = key;
    _lastSpeakAt = now;
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  Future<void> speakMessage(String message, {String? dedupeKey}) async {
    if (!_initialized || message.trim().isEmpty) {
      return;
    }

    final trimmed = message.trim();
    final key = dedupeKey ?? 'message:$trimmed';
    if (_lastDedupeKey == key) {
      return;
    }

    _lastDedupeKey = key;
    _lastSpeakAt = DateTime.now();
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  Future<void> speakRiskAlert({
    required String text,
    required String alertId,
    bool highPriority = false,
  }) async {
    if (!_initialized || text.trim().isEmpty) {
      return;
    }

    final key = 'alert:$alertId';
    final now = DateTime.now();
    if (_lastDedupeKey == key) {
      return;
    }
    if (!highPriority &&
        _lastSpeakAt != null &&
        now.difference(_lastSpeakAt!) < _minSpeakInterval) {
      return;
    }

    _lastDedupeKey = key;
    _lastSpeakAt = now;
    await _tts.stop();
    await _tts.speak(text.trim());
  }

  void resetStepTracking() {
    _lastDedupeKey = null;
    _lastSpeakAt = null;
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}

String navigationTtsLanguageCode(String languageCode) {
  switch (languageCode) {
    case 'es':
      return 'es-ES';
    default:
      return 'en-US';
  }
}
