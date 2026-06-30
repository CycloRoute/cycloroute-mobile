import 'dart:io';



import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';

import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

import 'package:cyclerisk/core/providers/auth_provider.dart';

import 'package:cyclerisk/core/providers/location_provider.dart';

import 'package:cyclerisk/core/services/api_exception.dart';

import 'package:cyclerisk/core/theme/app_colors.dart';

import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';

import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';

import 'package:cyclerisk/l10n/app_localizations.dart';



class ReviewerCaptureScreen extends StatefulWidget {

  const ReviewerCaptureScreen({super.key});



  @override

  State<ReviewerCaptureScreen> createState() => _ReviewerCaptureScreenState();

}



class _ReviewerCaptureScreenState extends State<ReviewerCaptureScreen> {

  final InfrastructureApiService _apiService = InfrastructureApiService();

  final ImagePicker _picker = ImagePicker();



  String? _imagePath;

  bool _isSubmitting = false;

  String? _errorMessage;

  InfrastructureAnalysisResult? _result;



  Future<void> _pickImage(ImageSource source) async {

    final file = await _picker.pickImage(

      source: source,

      imageQuality: 85,

      maxWidth: 1920,

    );

    if (file == null || !mounted) return;

    setState(() {

      _imagePath = file.path;

      _result = null;

      _errorMessage = null;

    });

  }



  Future<void> _submit() async {

    final l10n = appL10n(context);

    final imagePath = _imagePath;

    final token = context.read<AuthProvider>().accessToken;

    final location = context.read<LocationProvider>().currentLocation;



    if (imagePath == null) {

      setState(() => _errorMessage = l10n.takePhotoFirst);

      return;

    }

    if (token == null || token.isEmpty) {

      setState(() => _errorMessage = l10n.pleaseSignInAgain);

      return;

    }

    if (location == null) {

      setState(() => _errorMessage = l10n.waitingForGps);

      return;

    }



    setState(() {

      _isSubmitting = true;

      _errorMessage = null;

    });



    try {

      final result = await _apiService.analyze(

        accessToken: token,

        imagePath: imagePath,

        latitude: location.latitude,

        longitude: location.longitude,

      );



      if (!mounted) return;

      setState(() => _result = result);

    } on ApiException catch (e) {

      if (!mounted) return;

      setState(() => _errorMessage = localizeApiError(l10n, e));

    } catch (_) {

      if (!mounted) return;

      setState(() => _errorMessage = l10n.couldNotUploadAnalysis);

    } finally {

      if (mounted) {

        setState(() => _isSubmitting = false);

      }

    }

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



  @override

  Widget build(BuildContext context) {

    final l10n = appL10n(context);

    final result = _result;



    return Scaffold(

      appBar: AppBar(

        title: Text(l10n.reviewInfrastructure),

        backgroundColor: AppColors.background,

        surfaceTintColor: Colors.transparent,

      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          Text(

            l10n.captureInfrastructure,

            style: Theme.of(context).textTheme.titleLarge?.copyWith(

              fontWeight: FontWeight.w800,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            l10n.reviewerCaptureHint,

            style: Theme.of(context).textTheme.bodyMedium?.copyWith(

              color: AppColors.textSecondary,

            ),

          ),

          const SizedBox(height: 20),

          Row(

            children: [

              Expanded(

                child: OutlinedButton.icon(

                  onPressed: _isSubmitting

                      ? null

                      : () => _pickImage(ImageSource.camera),

                  icon: const Icon(Icons.photo_camera_outlined),

                  label: Text(l10n.camera),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: OutlinedButton.icon(

                  onPressed: _isSubmitting

                      ? null

                      : () => _pickImage(ImageSource.gallery),

                  icon: const Icon(Icons.photo_library_outlined),

                  label: Text(l10n.gallery),

                ),

              ),

            ],

          ),

          if (_imagePath != null) ...[

            const SizedBox(height: 16),

            ClipRRect(

              borderRadius: BorderRadius.circular(16),

              child: Image.file(

                File(_imagePath!),

                height: 180,

                width: double.infinity,

                fit: BoxFit.cover,

              ),

            ),

          ],

          const SizedBox(height: 16),

          if (_errorMessage != null)

            Text(

              _errorMessage!,

              style: const TextStyle(color: AppColors.alertRed),

            ),

          SizedBox(

            width: double.infinity,

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

                  : Text(l10n.analyzeAndSubmit),

            ),

          ),

          if (result != null) ...[

            const SizedBox(height: 24),

            Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: _qualityColor(result.quality).withOpacity(0.08),

                borderRadius: BorderRadius.circular(16),

                border: Border.all(

                  color: _qualityColor(result.quality).withOpacity(0.25),

                ),

              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'Score ${result.score} • ${result.quality}',

                    style: Theme.of(context).textTheme.titleMedium?.copyWith(

                      fontWeight: FontWeight.w800,

                      color: _qualityColor(result.quality),

                    ),

                  ),

                  const SizedBox(height: 8),

                  Text(

                    l10n.reportImprovedMap,

                    style: Theme.of(context).textTheme.bodyMedium,

                  ),

                  const SizedBox(height: 8),

                  Text(

                    l10n.graphEdgesUpdated(result.graphUpdate.edgesUpdated),

                  ),

                  if (result.detections.isNotEmpty) ...[

                    const SizedBox(height: 12),

                    Text(

                      l10n.detections,

                      style: Theme.of(context).textTheme.titleSmall,

                    ),

                    ...result.detections.map(

                      (item) => Text(

                        '• ${item.className} (${(item.confidence * 100).round()}%)',

                      ),

                    ),

                  ],

                ],

              ),

            ),

          ],

        ],

      ),

    );

  }

}

