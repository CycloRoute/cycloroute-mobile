import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

class NavigationAudioSessionService {
  const NavigationAudioSessionService._();

  static bool _active = false;

  static Future<void> activate() async {
    if (kIsWeb || _active) {
      return;
    }

    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.assistanceNavigationGuidance,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
        ),
      );
      _active = true;
    } catch (e) {
      debugPrint('NavigationAudioSessionService.activate failed: $e');
    }
  }

  static Future<void> deactivate() async {
    if (!_active) {
      return;
    }

    _active = false;
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      debugPrint('NavigationAudioSessionService.deactivate failed: $e');
    }
  }
}
