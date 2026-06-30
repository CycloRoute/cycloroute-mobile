import 'package:cyclerisk/features/navigation/domain/route_alerts_builder.dart';
import 'package:cyclerisk/features/risk_alert/data/models/risk_alert.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';

class RouteAlertsResolver {
  const RouteAlertsResolver._();

  static List<RiskAlert> resolve(RouteOption route) {
    final fromApi = route.alertsAlongRoute;
    if (fromApi != null && fromApi.isNotEmpty) {
      return fromApi;
    }

    final segments = route.segments;
    if (segments == null || segments.isEmpty) {
      return const [];
    }

    return RouteAlertsBuilder.build(
      segments: segments,
      coordinates: route.coordinates,
    );
  }
}
