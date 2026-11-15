import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/domain/route_score_explanation.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const higher =
      'El puntaje más alto no la hace más segura: tiene menos ciclovía.';
  const lower =
      'El puntaje puede ser menor porque prioriza ciclovía evaluada.';

  RouteOption route({
    required String id,
    required double score,
    required double infra,
    List<String> why = const [],
  }) {
    return RouteOption(
      routeId: id,
      distanceM: 1000,
      cycloScore: score,
      coordinates: const [GeoPoint(lat: 0, lng: 0)],
      why: why,
      rawPayload: {'bike_infrastructure_coverage': infra},
    );
  }

  test('a higher score with less bike infrastructure is not presented as safer', () {
    final shorter = route(id: 'shorter', score: 0.73, infra: 0, why: const [
      'Menor distancia total',
    ]);
    final recommended = route(
      id: 'recommended',
      score: 0.67,
      infra: 0.42,
      why: const ['Prioriza ciclovias'],
    );

    final shorterReasons = explainedRouteReasons(
      route: shorter,
      options: [shorter, recommended],
      higherScoreIsNotSafer: higher,
      lowerScorePrioritizesInfra: lower,
    );
    final recommendedReasons = explainedRouteReasons(
      route: recommended,
      options: [shorter, recommended],
      higherScoreIsNotSafer: higher,
      lowerScorePrioritizesInfra: lower,
    );

    expect(shorterReasons, contains(higher));
    expect(shorterReasons, isNot(contains(lower)));
    expect(recommendedReasons, contains(lower));
    expect(recommendedReasons, isNot(contains(higher)));
    expect(shorter.cycloScore, 0.73);
    expect(recommended.cycloScore, 0.67);
  });
}
