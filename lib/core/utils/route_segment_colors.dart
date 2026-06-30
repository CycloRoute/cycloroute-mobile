import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';

class RouteSegmentColors {
  const RouteSegmentColors._();

  static Color forCondition(String? condition) {
    return switch (condition?.toLowerCase()) {
      'good' => AppColors.safeGreen,
      'regular' => AppColors.riskYellow,
      'poor' => AppColors.alertRed,
      _ => AppColors.textSecondary,
    };
  }

  static Color forRiskLevel(String? riskLevel) {
    return switch (riskLevel?.toLowerCase()) {
      'low' => AppColors.safeGreen,
      'medium' => AppColors.riskYellow,
      'high' => AppColors.alertRed,
      _ => AppColors.textSecondary,
    };
  }

  /// Prefers [condition] when set; falls back to [riskLevel].
  static Color forSegment({String? condition, String? riskLevel}) {
    if (condition != null && condition.isNotEmpty) {
      return forCondition(condition);
    }
    return forRiskLevel(riskLevel);
  }
}
