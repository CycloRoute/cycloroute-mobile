enum CycloMapMode { user, moderation }

class CycloMapLayers {
  const CycloMapLayers({
    this.showUserLocation = false,
    this.showRoutes = false,
    this.showCommunityObstacles = false,
    this.showInfrastructureIa = false,
    this.showGraphCoverage = false,
    this.showPendingItems = false,
  });

  final bool showUserLocation;
  final bool showRoutes;
  final bool showCommunityObstacles;
  final bool showInfrastructureIa;
  final bool showGraphCoverage;
  final bool showPendingItems;

  static const home = CycloMapLayers(showUserLocation: true);

  static const routePreview = CycloMapLayers(showRoutes: true);

  static const navigation = CycloMapLayers(
    showUserLocation: true,
    showRoutes: true,
  );

  static const locationPicker = CycloMapLayers(showUserLocation: true);

  static const reportPin = CycloMapLayers();

  static const reviewer = CycloMapLayers(
    showUserLocation: true,
    showCommunityObstacles: true,
    showInfrastructureIa: true,
    showGraphCoverage: true,
    showPendingItems: true,
  );

  CycloMapLayers copyWith({
    bool? showUserLocation,
    bool? showRoutes,
    bool? showCommunityObstacles,
    bool? showInfrastructureIa,
    bool? showGraphCoverage,
    bool? showPendingItems,
  }) {
    return CycloMapLayers(
      showUserLocation: showUserLocation ?? this.showUserLocation,
      showRoutes: showRoutes ?? this.showRoutes,
      showCommunityObstacles:
          showCommunityObstacles ?? this.showCommunityObstacles,
      showInfrastructureIa: showInfrastructureIa ?? this.showInfrastructureIa,
      showGraphCoverage: showGraphCoverage ?? this.showGraphCoverage,
      showPendingItems: showPendingItems ?? this.showPendingItems,
    );
  }
}
