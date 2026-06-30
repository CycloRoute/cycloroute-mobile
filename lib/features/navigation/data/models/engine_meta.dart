import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';

class EngineMeta {
  const EngineMeta({
    this.version,
    this.computeMs,
    this.context,
    this.bikeProfile,
  });

  final String? version;
  final int? computeMs;
  final String? context;
  final BikeProfile? bikeProfile;

  factory EngineMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EngineMeta();
    }

    final bikeProfileRaw = json['bike_profile']?.toString();
    return EngineMeta(
      version: json['version']?.toString(),
      computeMs: (json['compute_ms'] as num?)?.toInt(),
      context: json['context']?.toString(),
      bikeProfile: bikeProfileRaw == null
          ? null
          : BikeProfile.fromApi(bikeProfileRaw),
    );
  }
}