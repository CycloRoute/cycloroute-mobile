import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';

import 'package:provider/provider.dart';

import 'package:cyclerisk/core/providers/auth_provider.dart';

import 'package:cyclerisk/core/providers/location_provider.dart';

import 'package:cyclerisk/core/services/api_exception.dart';

import 'package:cyclerisk/core/theme/app_colors.dart';

import 'package:cyclerisk/features/route_results/data/services/route_api_service.dart';

import 'package:cyclerisk/features/route_search/data/models/geo_point.dart';

import 'package:cyclerisk/l10n/app_localizations.dart';



class ReviewerToolsScreen extends StatefulWidget {

  const ReviewerToolsScreen({super.key});



  @override

  State<ReviewerToolsScreen> createState() => _ReviewerToolsScreenState();

}



class _ReviewerToolsScreenState extends State<ReviewerToolsScreen> {

  final RouteApiService _routeApiService = RouteApiService();

  bool _loadingHealth = false;

  bool _loadingDebug = false;

  String? _healthJson;

  String? _debugJson;

  String? _errorMessage;



  Future<void> _loadEngineHealth() async {

    final l10n = appL10n(context);

    final token = context.read<AuthProvider>().accessToken;

    if (token == null) return;



    setState(() {

      _loadingHealth = true;

      _errorMessage = null;

    });



    try {

      final result = await _routeApiService.getEngineHealth(

        accessToken: token,

      );

      if (!mounted) return;

      setState(() => _healthJson = const JsonEncoder.withIndent('  ').convert(result));

    } on ApiException catch (e) {

      if (!mounted) return;

      setState(() => _errorMessage = localizeApiError(l10n, e));

    } catch (_) {

      if (!mounted) return;

      setState(() => _errorMessage = l10n.couldNotLoadEngineHealth);

    } finally {

      if (mounted) setState(() => _loadingHealth = false);

    }

  }



  Future<void> _runRouteDebug() async {

    final l10n = appL10n(context);

    final token = context.read<AuthProvider>().accessToken;

    final location = context.read<LocationProvider>().currentLocation;

    if (token == null) return;



    if (location == null) {

      setState(() => _errorMessage = l10n.gpsRequiredForDebug);

      return;

    }



    setState(() {

      _loadingDebug = true;

      _errorMessage = null;

    });



    try {

      final result = await _routeApiService.getRouteOptionsDebug(

        accessToken: token,

        origin: GeoPoint(lat: location.latitude, lng: location.longitude),

        destination: GeoPoint(

          lat: location.latitude + 0.01,

          lng: location.longitude + 0.01,

        ),

      );

      if (!mounted) return;

      setState(() => _debugJson = const JsonEncoder.withIndent('  ').convert(result));

    } on ApiException catch (e) {

      if (!mounted) return;

      setState(() => _errorMessage = localizeApiError(l10n, e));

    } catch (_) {

      if (!mounted) return;

      setState(() => _errorMessage = l10n.couldNotRunRouteDebug);

    } finally {

      if (mounted) setState(() => _loadingDebug = false);

    }

  }



  @override

  Widget build(BuildContext context) {

    final l10n = appL10n(context);



    return Scaffold(

      appBar: AppBar(

        title: Text(l10n.reviewerTools),

        backgroundColor: AppColors.background,

        surfaceTintColor: Colors.transparent,

      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          Text(

            l10n.engineDiagnostics,

            style: Theme.of(context).textTheme.titleLarge?.copyWith(

              fontWeight: FontWeight.w800,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            l10n.reviewerToolsHint,

            style: Theme.of(context).textTheme.bodyMedium?.copyWith(

              color: AppColors.textSecondary,

            ),

          ),

          if (_errorMessage != null) ...[

            const SizedBox(height: 12),

            Text(

              _errorMessage!,

              style: const TextStyle(color: AppColors.alertRed),

            ),

          ],

          const SizedBox(height: 16),

          ElevatedButton(

            onPressed: _loadingHealth ? null : _loadEngineHealth,

            child: _loadingHealth

                ? const SizedBox(

                    width: 18,

                    height: 18,

                    child: CircularProgressIndicator(strokeWidth: 2),

                  )

                : const Text('GET /routes/engine-health'),

          ),

          if (_healthJson != null) ...[

            const SizedBox(height: 12),

            _JsonCard(title: l10n.engineHealth, body: _healthJson!),

          ],

          const SizedBox(height: 20),

          ElevatedButton(

            onPressed: _loadingDebug ? null : _runRouteDebug,

            child: _loadingDebug

                ? const SizedBox(

                    width: 18,

                    height: 18,

                    child: CircularProgressIndicator(strokeWidth: 2),

                  )

                : const Text('POST /routes/options/debug'),

          ),

          if (_debugJson != null) ...[

            const SizedBox(height: 12),

            _JsonCard(title: l10n.routeDebug, body: _debugJson!),

          ],

        ],

      ),

    );

  }

}



class _JsonCard extends StatelessWidget {

  const _JsonCard({required this.title, required this.body});



  final String title;

  final String body;



  @override

  Widget build(BuildContext context) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(12),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(title, style: Theme.of(context).textTheme.titleSmall),

            const SizedBox(height: 8),

            SelectableText(

              body,

              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),

            ),

          ],

        ),

      ),

    );

  }

}

