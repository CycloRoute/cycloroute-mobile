import 'package:cyclerisk/features/route_results/data/models/route_option.dart';

List<String> explainedRouteReasons({
  required RouteOption route,
  required Iterable<RouteOption> options,
  required String higherScoreIsNotSafer,
  required String lowerScorePrioritizesInfra,
}) {
  final reasons = List<String>.from(route.why);
  final others = options.where((other) => other.routeId != route.routeId);
  final outscoresWithLessInfra = others.any(
    (other) =>
        route.bikeInfrastructureCoverage < other.bikeInfrastructureCoverage &&
        route.cycloScore > other.cycloScore,
  );
  final outscoredDespiteMoreInfra = others.any(
    (other) =>
        route.bikeInfrastructureCoverage > other.bikeInfrastructureCoverage &&
        route.cycloScore < other.cycloScore,
  );

  if (outscoresWithLessInfra && !reasons.contains(higherScoreIsNotSafer)) {
    reasons.add(higherScoreIsNotSafer);
  }
  if (outscoredDespiteMoreInfra &&
      !reasons.contains(lowerScorePrioritizesInfra)) {
    reasons.add(lowerScorePrioritizesInfra);
  }
  return reasons;
}
