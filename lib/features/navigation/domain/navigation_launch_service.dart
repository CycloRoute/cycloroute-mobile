import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/navigation/data/models/navigation_launch_args.dart';
import 'package:cyclerisk/features/navigation/data/repositories/navigation_cache_repository.dart';
import 'package:cyclerisk/features/navigation/data/services/navigation_api_service.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class NavigationLaunchService {
  NavigationLaunchService({
    NavigationApiService? navigationApiService,
    NavigationCacheRepository? cacheRepository,
  }) : _navigationApiService = navigationApiService ?? NavigationApiService(),
       _cacheRepository = cacheRepository ?? NavigationCacheRepository();

  final NavigationApiService _navigationApiService;
  final NavigationCacheRepository _cacheRepository;

  Future<void> launch({
    required BuildContext context,
    required RouteOption route,
    required GeoPoint destination,
    GeoPoint? origin,
    String? originLabel,
    String? destinationLabel,
    RoutePreference? preference,
    BikeProfile? bikeProfile,
  }) async {
    final l10n = appL10n(context);
    final accessToken = context.read<AuthProvider>().accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception(l10n.pleaseSignInToCalculateRoutes);
    }

    final resolvedPreference =
        preference ?? RoutePreference.fromApi(route.routeId);
    final resolvedBikeProfile =
        bikeProfile ?? context.read<BikeProfileProvider>().profile;

    final session = await _navigationApiService.startNavigation(
      accessToken: accessToken,
      destination: destination,
      activeRouteId: resolvedPreference,
      origin: origin,
    );

    await _cacheRepository.save(
      NavigationCacheData(
        session: session,
        activeRoute: route,
        preference: resolvedPreference,
        bikeProfile: resolvedBikeProfile,
        destination: destination,
        origin: origin,
        originLabel: originLabel,
        destinationLabel: destinationLabel,
      ),
    );

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).pushNamed(
      AppRoutes.navigation,
      arguments: NavigationLaunchArgs(
        session: session,
        activeRoute: route,
        preference: resolvedPreference,
        bikeProfile: resolvedBikeProfile,
        destination: destination,
        origin: origin,
        originLabel: originLabel,
        destinationLabel: destinationLabel,
      ),
    );
  }

  static String? errorMessage(AppLocalizations l10n, Object error) {
    if (error is ApiException) {
      return localizeApiError(l10n, error);
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return l10n.couldNotStartNavigation;
  }
}
