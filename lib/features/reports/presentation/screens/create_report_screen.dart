import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/features/map/domain/cyclo_map_layers.dart';
import 'package:cyclerisk/features/map/presentation/widgets/cyclo_map.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';
import 'package:cyclerisk/features/reports/data/services/reports_api_service.dart';
import 'package:cyclerisk/features/reports/presentation/utils/obstacle_category_label.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final ReportsApiService _reportsApiService = ReportsApiService();
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();

  LatLng? _pinLocation;
  ObstacleCategory _category = ObstacleCategory.blockedLane;
  ObstacleSeverity _severity = ObstacleSeverity.medium;
  bool _isSubmitting = false;
  bool _mapReady = false;
  String? _errorMessage;
  Timer? _initTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePin());
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializePin() async {
    LatLng? center = widget.initialLocation;
    if (center == null) {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.currentLocation == null) {
        await locationProvider.getCurrentLocation();
      }
      final current = locationProvider.currentLocation;
      if (current != null) {
        center = LatLng(current.latitude, current.longitude);
      }
    }

    center ??= LatLng(-12.0464, -77.0428);
    if (!mounted) return;

    setState(() {
      _pinLocation = center;
      _mapReady = true;
    });

    _initTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _mapController.move(center!, 16);
    });
  }

  Future<void> _useMyLocation() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.getCurrentLocation();
    final current = locationProvider.currentLocation;
    if (current == null || !mounted) {
      setState(() => _errorMessage = appL10n(context).waitingForGps);
      return;
    }

    final point = LatLng(current.latitude, current.longitude);
    setState(() {
      _pinLocation = point;
      _errorMessage = null;
    });
    _mapController.move(point, 16);
  }

  void _onMapMoved(MapPosition position) {
    final center = position.center;
    if (center == null) return;
    setState(() => _pinLocation = center);
  }

  Future<void> _submit() async {
    final l10n = appL10n(context);
    final description = _descriptionController.text.trim();
    final token = context.read<AuthProvider>().accessToken;
    final pin = _pinLocation;

    if (description.isEmpty) {
      setState(() => _errorMessage = l10n.describeObstacle);
      return;
    }
    if (token == null || token.isEmpty) {
      setState(() => _errorMessage = l10n.pleaseSignInAgain);
      return;
    }
    if (pin == null) {
      setState(() => _errorMessage = l10n.waitingForGps);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _reportsApiService.createReport(
        accessToken: token,
        lat: pin.latitude,
        lng: pin.longitude,
        description: description,
        category: _category,
        severity: _severity,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.communityReportPendingMessage)),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotSubmitReport);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);
    final pin = _pinLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportObstacle),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            l10n.manualObstacleReport,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.obstacleReportHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.pinObstacleLocation,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adjustPinOnMap,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: _mapReady && pin != null
                  ? CycloMap(
                      mapController: _mapController,
                      center: pin,
                      zoom: 16,
                      height: 220,
                      borderRadius: 0,
                      layers: CycloMapLayers.reportPin,
                      showCenterPin: true,
                      onPositionChanged: (position, _) => _onMapMoved(position),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isSubmitting ? null : _useMyLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: Text(l10n.useMyLocation),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.obstacleCategoryTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ObstacleCategory.values.map((category) {
              final selected = _category == category;
              return ChoiceChip(
                label: Text(ObstacleCategoryLabel.category(l10n, category)),
                selected: selected,
                onSelected: _isSubmitting
                    ? null
                    : (_) => setState(() => _category = category),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.obstacleSeverityTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ObstacleSeverity>(
            segments: ObstacleSeverity.values
                .map(
                  (value) => ButtonSegment(
                    value: value,
                    label: Text(ObstacleCategoryLabel.severity(l10n, value)),
                  ),
                )
                .toList(),
            selected: {_severity},
            onSelectionChanged: _isSubmitting
                ? null
                : (selection) {
                    setState(() => _severity = selection.first);
                  },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.description,
              hintText: l10n.obstacleDescriptionHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.alertRed),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.submitReport),
            ),
          ),
        ],
      ),
    );
  }
}
