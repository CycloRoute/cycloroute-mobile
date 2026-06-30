import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class DistanceFormat {
  const DistanceFormat({
    required this.unit,
    required this.l10n,
  });

  final DistanceUnit unit;
  final AppLocalizations l10n;

  static const _feetPerMeter = 3.280839895;
  static const _metersPerMile = 1609.344;

  String formatStepDistance(int meters) {
    if (meters <= 0) {
      return '';
    }

    if (unit == DistanceUnit.miles) {
      final feet = (meters * _feetPerMeter).round();
      if (feet < 528) {
        return l10n.inFeet(feet);
      }
      final miles = meters / _metersPerMile;
      return l10n.inMilesDistance(_formatOneDecimal(miles));
    }

    return l10n.inMeters(meters);
  }

  String ttsApproachDistance(int meters) {
    if (unit == DistanceUnit.miles) {
      final feet = (meters * _feetPerMeter).round();
      return l10n.ttsInFeet(feet);
    }

    return l10n.ttsInMeters(meters);
  }

  String formatRouteDistance(double distanceM) {
    if (unit == DistanceUnit.miles) {
      final miles = distanceM / _metersPerMile;
      return l10n.routeDistanceMi(_formatOneDecimal(miles));
    }

    final km = distanceM / 1000;
    return l10n.routeDistanceKm(_formatOneDecimal(km));
  }

  String _formatOneDecimal(double value) {
    return value.toStringAsFixed(1);
  }
}
