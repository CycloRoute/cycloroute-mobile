import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';

RouteOption? pickRouteForPreference(
  List<RouteOption> routes,
  RoutePreference preference,
) {
  if (routes.isEmpty) {
    return null;
  }

  for (final route in routes) {
    if (route.routeId.toLowerCase() == preference.apiValue) {
      return route;
    }
  }

  return routes.first;
}
