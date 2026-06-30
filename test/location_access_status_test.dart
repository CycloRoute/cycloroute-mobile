import 'package:cyclerisk/core/models/location_access_status.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationAccessStatus', () {
    test('maps geolocator permissions', () {
      expect(
        LocationAccessStatus.fromPermission(LocationPermission.whileInUse),
        LocationAccessStatus.granted,
      );
      expect(
        LocationAccessStatus.fromPermission(LocationPermission.always),
        LocationAccessStatus.granted,
      );
      expect(
        LocationAccessStatus.fromPermission(LocationPermission.denied),
        LocationAccessStatus.denied,
      );
      expect(
        LocationAccessStatus.fromPermission(LocationPermission.deniedForever),
        LocationAccessStatus.deniedForever,
      );
    });
  });
}
