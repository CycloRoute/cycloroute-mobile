import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/engine_meta.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class RouteOptionsResult {
  const RouteOptionsResult({
    required this.origin,
    required this.destination,
    required this.routes,
    this.originLabel,
    this.destinationLabel,
    this.engineMeta,
    this.planningPreference,
    this.bikeProfile,
  });

  final GeoPoint origin;
  final GeoPoint destination;
  final List<RouteOption> routes;
  final String? originLabel;
  final String? destinationLabel;
  final EngineMeta? engineMeta;
  final RoutePreference? planningPreference;
  final BikeProfile? bikeProfile;

  factory RouteOptionsResult.fromJson(
    Map<String, dynamic> json, {
    String? originLabel,
    String? destinationLabel,
    RoutePreference? planningPreference,
    BikeProfile? bikeProfile,
  }) {
    return RouteOptionsResult(
      origin: GeoPoint.fromJson(json['origin'] as Map<String, dynamic>),
      destination: GeoPoint.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      routes: (json['routes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RouteOption.fromJson)
          .toList(),
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      engineMeta: EngineMeta.fromJson(
        json['engine_meta'] as Map<String, dynamic>?,
      ),
      planningPreference: planningPreference,
      bikeProfile: bikeProfile,
    );
  }
}
