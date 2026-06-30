import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/config/app_config.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class RouteCoverageScreen extends StatefulWidget {
  const RouteCoverageScreen({super.key});

  @override
  State<RouteCoverageScreen> createState() => _RouteCoverageScreenState();
}

class _RouteCoverageScreenState extends State<RouteCoverageScreen> {
  final RouteApiService _routeApiService = RouteApiService();
  final MapController _mapController = MapController();
  Timer? _boundsDebounce;

  List<RouteCoveragePoint> _points = const [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().getCurrentLocation();
      _loadPoints();
    });
  }

  @override
  void dispose() {
    _boundsDebounce?.cancel();
    super.dispose();
  }

  String? _currentBounds() {
    final bounds = _mapController.bounds;
    if (bounds == null) return null;
    return '${bounds.south},${bounds.west},${bounds.north},${bounds.east}';
  }

  Future<void> _loadPoints() async {
    final l10n = appL10n(context);
    final token = context.read<AuthProvider>().accessToken;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final points = await _routeApiService.getCoverage(
        accessToken: token,
        bounds: _currentBounds(),
      );
      if (!mounted) return;
      setState(() => _points = points);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotLoadCoverage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scheduleReload() {
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 500), _loadPoints);
  }

  Color _pointColor(RouteCoveragePoint point) {
    final coverage = point.coverage;
    if (coverage == null) return AppColors.primary;
    if (coverage >= 0.8) return AppColors.safeGreen;
    if (coverage >= 0.5) return AppColors.riskYellow;
    return AppColors.alertRed;
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
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadPoints,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: center,
              zoom: 13,
              maxZoom: 18,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) _scheduleReload();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.mapTileUrlTemplate,
                subdomains: AppConfig.mapTileSubdomains,
                userAgentPackageName: 'com.cyclerisk.app',
              ),
              MarkerLayer(
                markers: [
                  if (location != null)
                    Marker(
                      point: location,
                      width: 36,
                      height: 36,
                      builder: (_) => const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                      ),
                    ),
                  ..._points.map(
                    (point) => Marker(
                      point: LatLng(point.latitude, point.longitude),
                      width: 20,
                      height: 20,
                      builder: (_) => Container(
                        decoration: BoxDecoration(
                          color: _pointColor(point),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_errorMessage != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.alertRed),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
