import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class SavedRouteMeta {
  const SavedRouteMeta({
    required this.origin,
    required this.destination,
    this.originLabel,
    this.destinationLabel,
    this.planningPreference,
    this.bikeProfile,
  });

  final GeoPoint origin;
  final GeoPoint destination;
  final String? originLabel;
  final String? destinationLabel;
  final RoutePreference? planningPreference;
  final BikeProfile? bikeProfile;

  static const storageKey = '_saved_meta';

  Map<String, dynamic> toJson() {
    return {
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      if (originLabel != null) 'origin_label': originLabel,
      if (destinationLabel != null) 'destination_label': destinationLabel,
      if (planningPreference != null)
        'planning_preference': planningPreference!.apiValue,
      if (bikeProfile != null) 'bike_profile': bikeProfile!.apiValue,
    };
  }

  factory SavedRouteMeta.fromJson(Map<String, dynamic> json) {
    return SavedRouteMeta(
      origin: GeoPoint.fromJson(json['origin'] as Map<String, dynamic>),
      destination: GeoPoint.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      originLabel: json['origin_label']?.toString(),
      destinationLabel: json['destination_label']?.toString(),
      planningPreference: json['planning_preference'] == null
          ? null
          : RoutePreference.fromApi(json['planning_preference']?.toString()),
      bikeProfile: json['bike_profile'] == null
          ? null
          : BikeProfile.fromApi(json['bike_profile']?.toString()),
    );
  }
}
