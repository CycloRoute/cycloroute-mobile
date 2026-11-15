import 'package:cyclerisk/features/navigation/domain/navigation_session_controller.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a failed reroute clears the recalculating banner and keeps the route', () {
    final controller = NavigationSessionController();
    addTearDown(controller.dispose);

    const route = RouteOption(
      routeId: 'route-1',
      distanceM: 1200,
      cycloScore: 0.7,
      coordinates: [
        GeoPoint(lat: -12.1, lng: -77.03),
        GeoPoint(lat: -12.11, lng: -77.04),
      ],
    );
    controller.activeRoute = route;
    controller.isRerouting = true;
    controller.bannerMessage = 'recalculating';

    controller.markRerouteFailedForTest();

    expect(controller.bannerMessage, NavigationSessionController.rerouteFailedBanner);
    expect(controller.errorMessage, isNull);
    expect(controller.activeRoute, same(route));
    expect(controller.isRerouting, isFalse);
  });
}
