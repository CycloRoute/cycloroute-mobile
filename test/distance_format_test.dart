import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/utils/distance_format.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DistanceFormat', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('formats step distance in meters for kilometers', () {
      final format = DistanceFormat(
        unit: DistanceUnit.kilometers,
        l10n: l10n,
      );

      expect(format.formatStepDistance(250), 'In 250 m');
      expect(format.formatStepDistance(0), '');
    });

    test('formats step distance in feet for short imperial segments', () {
      final format = DistanceFormat(
        unit: DistanceUnit.miles,
        l10n: l10n,
      );

      expect(format.formatStepDistance(100), 'In 328 ft');
    });

    test('formats route distance with selected unit', () {
      final kmFormat = DistanceFormat(
        unit: DistanceUnit.kilometers,
        l10n: l10n,
      );
      final miFormat = DistanceFormat(
        unit: DistanceUnit.miles,
        l10n: l10n,
      );

      expect(kmFormat.formatRouteDistance(5200), '5.2 km');
      expect(miFormat.formatRouteDistance(1609.344), '1.0 mi');
    });

    test('formats TTS approach distance', () {
      final kmFormat = DistanceFormat(
        unit: DistanceUnit.kilometers,
        l10n: l10n,
      );
      final miFormat = DistanceFormat(
        unit: DistanceUnit.miles,
        l10n: l10n,
      );

      expect(kmFormat.ttsApproachDistance(80), 'In 80 meters');
      expect(miFormat.ttsApproachDistance(30), 'In 98 feet');
    });
  });
}
