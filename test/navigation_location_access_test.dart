import 'package:flutter_test/flutter_test.dart';
import 'package:cyclerisk/core/models/navigation_location_access.dart';

void main() {
  group('NavigationLocationAccess', () {
    test('foregroundOnly is usable but not background', () {
      const access = NavigationLocationAccess.foregroundOnly;
      expect(access.isUsable, isTrue);
      expect(access.hasBackgroundAccess, isFalse);
    });

    test('background is fully usable', () {
      const access = NavigationLocationAccess.background;
      expect(access.isUsable, isTrue);
      expect(access.hasBackgroundAccess, isTrue);
    });

    test('denied is not usable', () {
      const access = NavigationLocationAccess.denied;
      expect(access.isUsable, isFalse);
      expect(access.hasBackgroundAccess, isFalse);
    });
  });
}
