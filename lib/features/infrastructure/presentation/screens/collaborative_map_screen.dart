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
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class CollaborativeMapScreen extends StatefulWidget {
  const CollaborativeMapScreen({super.key});

  @override
  State<CollaborativeMapScreen> createState() => _CollaborativeMapScreenState();
}

class _CollaborativeMapScreenState extends State<CollaborativeMapScreen> {
  final InfrastructureApiService _apiService = InfrastructureApiService();
  final MapController _mapController = MapController();

  List<InfrastructureMapPoint> _points = const [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _boundsDebounce;

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

  Color _qualityColor(String quality) {
    switch (quality.toUpperCase()) {
      case 'GOOD':
        return AppColors.safeGreen;
      case 'BAD':
        return AppColors.alertRed;
      default:
        return AppColors.riskYellow;
    }
  }

  String? _currentBounds() {
    final bounds = _mapController.bounds;
    if (bounds == null) {
      return null;
    }

    return '${bounds.south},${bounds.west},${bounds.north},${bounds.east}';
  }

  Future<void> _loadPoints() async {
    final l10n = appL10n(context);
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseSignInAgain);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final points = await _apiService.getMapPoints(
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
      setState(() => _errorMessage = l10n.couldNotLoadCollaborativeMap);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scheduleReload() {
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 500), _loadPoints);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final location = context.watch<LocationProvider>().currentLocation;
    final center = location ?? LatLng(-12.0464, -77.0428);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collaborativeMap),
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
              zoom: 14,
              maxZoom: 18,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  _scheduleReload();
                }
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
                      width: 40,
                      height: 40,
                      builder: (_) => const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ..._points.map(
                    (point) => Marker(
                      point: LatLng(point.latitude, point.longitude),
                      width: 28,
                      height: 28,
                      builder: (_) => Container(
                        decoration: BoxDecoration(
                          color: _qualityColor(point.quality),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
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
