class Route {
  final String id;
  final String name;
  final double distance; // in km
  final int duration; // in minutes
  final String riskLevel; // 'low', 'medium', 'high'
  final double riskScore; // 0-100
  final List<String> waypoints;

  Route({
    required this.id,
    required this.name,
    required this.distance,
    required this.duration,
    required this.riskLevel,
    required this.riskScore,
    required this.waypoints,
  });
}

class MockRoutes {
  static List<Route> getSampleRoutes() {
    return [
      Route(
        id: 'route_1',
        name: 'Safest route',
        distance: 8.5,
        duration: 28,
        riskLevel: 'low',
        riskScore: 15.0,
        waypoints: [
          'Downtown Center',
          'Park Avenue',
          'Bike Lane North',
          'Safe Street',
          'Destination Point',
        ],
      ),
      Route(
        id: 'route_2',
        name: 'Shortest route',
        distance: 5.2,
        duration: 18,
        riskLevel: 'medium',
        riskScore: 55.0,
        waypoints: [
          'Downtown Center',
          'Main Street',
          'Intersection Road',
          'Direct Path',
          'Destination Point',
        ],
      ),
      Route(
        id: 'route_3',
        name: 'Balanced route',
        distance: 6.8,
        duration: 23,
        riskLevel: 'medium',
        riskScore: 38.0,
        waypoints: [
          'Downtown Center',
          'Commercial District',
          'Mid-level Lane',
          'Strategic Route',
          'Destination Point',
        ],
      ),
    ];
  }

  static Route getActiveRoute() {
    return getSampleRoutes()[0];
  }
}
