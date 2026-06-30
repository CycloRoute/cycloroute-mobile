import 'package:flutter_test/flutter_test.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/navigation/data/models/engine_meta.dart';

void main() {
  test('BikeProfile falls back to urban for unknown values', () {
    expect(BikeProfile.fromApi(null), BikeProfile.urban);
    expect(BikeProfile.fromApi('gravel'), BikeProfile.urban);
    expect(BikeProfile.fromApi('mtb'), BikeProfile.mtb);
    expect(BikeProfile.fromApi('electric'), BikeProfile.electric);
  });

  test('EngineMeta parses bike_profile from engine_meta', () {
    final meta = EngineMeta.fromJson({
      'version': '1.2.0',
      'compute_ms': 120,
      'context': 'planning',
      'bike_profile': 'electric',
    });

    expect(meta.bikeProfile, BikeProfile.electric);
    expect(meta.version, '1.2.0');
  });
}
