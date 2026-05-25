class Route {
  final String id;
  final String name;
  final double distance; // in km
  final int duration; // in minutes
  final String riskLevel; // kept for color/fit mapping
  final double riskScore; // kept as an internal fit score
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
        name: 'Protected lane route',
        distance: 8.5,
        duration: 28,
        riskLevel: 'low',
        riskScore: 15.0,
        waypoints: [
          'Downtown Center',
          'Park Avenue protected lane',
          'North bike corridor',
          'Quiet block connection',
          'Destination',
        ],
      ),
      Route(
        id: 'route_2',
        name: 'Fastest corridor',
        distance: 5.2,
        duration: 18,
        riskLevel: 'medium',
        riskScore: 55.0,
        waypoints: [
          'Downtown Center',
          'Main Street',
          'Signalized crossing',
          'Direct corridor',
          'Destination',
        ],
      ),
      Route(
        id: 'route_3',
        name: 'Balanced bike route',
        distance: 6.8,
        duration: 23,
        riskLevel: 'medium',
        riskScore: 38.0,
        waypoints: [
          'Downtown Center',
          'Commercial district',
          'Mixed-use avenue',
          'Buffered lane segment',
          'Destination',
        ],
      ),
    ];
  }

  static Route getActiveRoute() {
    return getSampleRoutes()[0];
  }
}
