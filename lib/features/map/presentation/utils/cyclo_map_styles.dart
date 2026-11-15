import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';

class CycloMapStyles {
  const CycloMapStyles._();

  static const obstacleColor = Color(0xFFFF8C00);

  static Color infrastructureQualityColor(String quality) {
    switch (quality.toUpperCase()) {
      case 'GOOD':
        return AppColors.safeGreen;
      case 'BAD':
        return AppColors.alertRed;
      default:
        return AppColors.riskYellow;
    }
  }

  static Color obstacleMarkerColor(ObstacleReport report) {
    if (report.isPending) return AppColors.textSecondary;
    return obstacleColor;
  }

  static BoxDecoration obstacleDecoration(ObstacleReport report) {
    final color = obstacleMarkerColor(report);
    if (report.isPending) {
      return BoxDecoration(
        color: color.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2, style: BorderStyle.solid),
      );
    }
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    );
  }

  static BoxDecoration infrastructureDecoration(InfrastructureMapPoint point) {
    final color = infrastructureQualityColor(point.quality);
    if (point.isPending) {
      return BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textSecondary, width: 2),
      );
    }
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    );
  }
}
