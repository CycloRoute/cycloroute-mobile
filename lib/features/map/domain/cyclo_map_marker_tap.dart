import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';

sealed class CycloMapMarkerTap {
  const CycloMapMarkerTap();
}

class CycloMapObstacleTap extends CycloMapMarkerTap {
  const CycloMapObstacleTap(this.report);

  final ObstacleReport report;
}

class CycloMapInfrastructureTap extends CycloMapMarkerTap {
  const CycloMapInfrastructureTap(this.point);

  final InfrastructureMapPoint point;
}
