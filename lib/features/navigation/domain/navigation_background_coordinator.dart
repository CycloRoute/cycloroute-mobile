import 'package:cyclerisk/core/services/navigation_audio_session_service.dart';
import 'package:cyclerisk/core/services/navigation_wakelock_service.dart';

typedef NavigationNotificationUpdater = void Function({
  required String title,
  required String text,
});

/// Hooks for platform background behavior during an active navigation session.
class NavigationBackgroundCoordinator {
  NavigationBackgroundCoordinator();

  NavigationNotificationUpdater? _onNotificationUpdate;
  String? _destinationLabel;
  String _fallbackText = 'Navigation active';

  void bindNotificationUpdater(NavigationNotificationUpdater updater) {
    _onNotificationUpdate = updater;
  }

  void setFallbackNotificationText(String text) {
    _fallbackText = text;
  }

  Future<void> onNavigationStarted({
    required String destinationLabel,
  }) async {
    _destinationLabel = destinationLabel;
    await NavigationAudioSessionService.activate();
    await NavigationWakelockService.enable();
  }

  Future<void> onNavigationEnded() async {
    _destinationLabel = null;
    await NavigationWakelockService.disable();
    await NavigationAudioSessionService.deactivate();
  }

  void onInstructionUpdated(String instruction) {
    final title = _destinationLabel ?? 'CycloRoute';
    final trimmed = instruction.trim();
    final text = trimmed.isEmpty ? _fallbackText : _truncate(trimmed, 140);
    _onNotificationUpdate?.call(title: title, text: text);
  }

  void onRiskAlertUpdated({
    required String title,
    required String body,
  }) {
    final alertTitle = title.trim().isEmpty ? 'CycloRoute' : _truncate(title, 64);
    final alertBody = body.trim().isEmpty ? _fallbackText : _truncate(body, 140);
    _onNotificationUpdate?.call(title: '⚠ $alertTitle', text: alertBody);
  }

  String get destinationLabel => _destinationLabel ?? 'CycloRoute';

  static String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 1)}…';
  }
}
