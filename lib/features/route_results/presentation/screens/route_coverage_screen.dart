import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map.dart';

class RouteCoverageScreen extends StatefulWidget {
  const RouteCoverageScreen({super.key});

  @override
  State<RouteCoverageScreen> createState() => _RouteCoverageScreenState();
}

class _RouteCoverageScreenState extends State<RouteCoverageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.currentLocation == null) {
        locationProvider.getCurrentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final location = context.watch<LocationProvider>().currentLocation;
    final center = location ?? LatLng(-12.0464, -77.0428);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiRouteCoverage),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: CycloMap(
        center: center,
        zoom: 13,
        height: double.infinity,
        borderRadius: 0,
        layers: const CycloMapLayers(
          showUserLocation: true,
          showGraphCoverage: true,
        ),
        mode: CycloMapMode.moderation,
        userLocation: location,
        showLegend: true,
      ),
    );
  }
}
