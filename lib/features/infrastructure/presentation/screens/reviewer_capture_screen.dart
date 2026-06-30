import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/services/infrastructure_api_service.dart';
import 'package:cyclerisk/features/infrastructure/presentation/screens/infrastructure_analysis_result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ReviewerCaptureScreen extends StatefulWidget {
  const ReviewerCaptureScreen({super.key});

  @override
  State<ReviewerCaptureScreen> createState() => _ReviewerCaptureScreenState();
}

class _ReviewerCaptureScreenState extends State<ReviewerCaptureScreen> {
  final InfrastructureApiService _apiService = InfrastructureApiService();
  final ImagePicker _picker = ImagePicker();

  String? _imageName;
  Uint8List? _imageBytes;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageName = file.name.isNotEmpty ? file.name : 'capture.jpg';
      _imageBytes = bytes;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final l10n = appL10n(context);
    final imageBytes = _imageBytes;
    final imageName = _imageName;
    final token = context.read<AuthProvider>().accessToken;
    final location = context.read<LocationProvider>().currentLocation;

    if (imageBytes == null) {
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
        imageBytes: imageBytes,
        filename: imageName ?? 'capture.jpg',
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => InfrastructureAnalysisResultScreen(
            args: InfrastructureAnalysisResultArgs(
              result: result,
              previewBytes: imageBytes,
            ),
          ),
        ),
      );

      if (!mounted) return;
      setState(() {
        _imageBytes = null;
        _imageName = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = localizeApiError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.couldNotUploadAnalysis);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.submitInfrastructureCapture),
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
          if (_imageBytes != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _imageBytes!,
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
        ],
      ),
    );
  }
}
