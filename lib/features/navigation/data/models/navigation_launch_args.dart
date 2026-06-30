import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_session.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

class NavigationLaunchArgs {
  const NavigationLaunchArgs({
    required this.session,
    required this.activeRoute,
    required this.preference,
    required this.destination,
    this.bikeProfile = BikeProfile.urban,
    this.origin,
    this.originLabel,
    this.destinationLabel,
    this.resumeStepIndex,
  });

  final NavigationSession session;
  final RouteOption activeRoute;
  final RoutePreference preference;
  final BikeProfile bikeProfile;
  final GeoPoint destination;
  final GeoPoint? origin;
  final String? originLabel;
  final String? destinationLabel;
  final int? resumeStepIndex;
}
