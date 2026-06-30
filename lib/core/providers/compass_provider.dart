import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassProvider extends ChangeNotifier {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double? _heading;
  DateTime? _lastNotificationAt;
  bool _isAvailable = true;

  double? get heading => _heading;
  bool get isAvailable => _isAvailable;

  void start() {
    if (_compassSubscription != null) {
      return;
    }

    final events = FlutterCompass.events;
    if (events == null) {
      _isAvailable = false;
      notifyListeners();
      return;
    }

    _compassSubscription = events.listen(
      (event) {
        final heading = event.heading;
        if (heading == null || heading.isNaN) {
          _isAvailable = false;
          notifyListeners();
          return;
        }

        final normalizedHeading = (heading + 360) % 360;
        final previousHeading = _heading;
        final smoothedHeading = previousHeading == null
            ? normalizedHeading
            : _smoothHeading(previousHeading, normalizedHeading);
        final now = DateTime.now();

        if (previousHeading != null &&
            _headingDelta(previousHeading, smoothedHeading) < 3.0 &&
            _lastNotificationAt != null &&
            now.difference(_lastNotificationAt!) <
                const Duration(milliseconds: 260)) {
          return;
        }

        _isAvailable = true;
        _heading = smoothedHeading;
        _lastNotificationAt = now;
        notifyListeners();
      },
      onError: (_) {
        _isAvailable = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  double _smoothHeading(double previous, double next) {
    final delta = _signedDelta(previous, next);
    return (previous + delta * 0.18 + 360) % 360;
  }

  double _headingDelta(double a, double b) => _signedDelta(a, b).abs();

  double _signedDelta(double from, double to) {
    var delta = (to - from + 540) % 360 - 180;
    if (delta == -180) {
      delta = 180;
    }
    return delta;
  }
}
