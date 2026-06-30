import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NavigationWakelockService {
  const NavigationWakelockService._();

  static bool _enabled = false;

  static Future<void> enable() async {
    if (kIsWeb || _enabled) {
      return;
    }

    try {
      await WakelockPlus.enable();
      _enabled = true;
    } catch (e) {
      debugPrint('NavigationWakelockService.enable failed: $e');
    }
  }

  static Future<void> disable() async {
    if (!_enabled) {
      return;
    }

    _enabled = false;
    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('NavigationWakelockService.disable failed: $e');
    }
  }
}
