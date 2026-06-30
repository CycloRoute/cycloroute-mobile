import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CycloMapLayers presets expose expected defaults', () {
    expect(CycloMapLayers.home.showUserLocation, isTrue);
    expect(CycloMapLayers.home.showCommunityObstacles, isFalse);

    expect(CycloMapLayers.routePreview.showRoutes, isTrue);
    expect(CycloMapLayers.routePreview.showUserLocation, isFalse);

    expect(CycloMapLayers.navigation.showUserLocation, isTrue);
    expect(CycloMapLayers.navigation.showRoutes, isTrue);

    expect(CycloMapLayers.reviewer.showPendingItems, isTrue);
    expect(CycloMapLayers.reviewer.showGraphCoverage, isTrue);
  });

  test('CycloMapLayers copyWith toggles layers', () {
    const base = CycloMapLayers.home;
    final toggled = base.copyWith(showCommunityObstacles: true);

    expect(toggled.showUserLocation, isTrue);
    expect(toggled.showCommunityObstacles, isTrue);
    expect(toggled.showInfrastructureIa, isFalse);
  });
}
