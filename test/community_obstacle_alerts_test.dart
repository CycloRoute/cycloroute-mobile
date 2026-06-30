import 'package:cyclerisk/features/reports/data/models/obstacle_category.dart';
import 'package:cyclerisk/features/reports/data/models/obstacle_report.dart';
import 'package:cyclerisk/features/reports/domain/community_obstacle_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps community report to risk alert with stable id', () {
    final alert = CommunityObstacleAlerts.toRiskAlert(
      ObstacleReport(
        id: 'abc-123',
        lat: -12.05,
        lng: -77.05,
        type: 'obstacle',
        description: 'Auto en ciclovía',
        category: ObstacleCategory.blockedLane,
        severity: ObstacleSeverity.high,
      ),
    );

    expect(alert.id, 'community-abc-123');
    expect(alert.type, 'community_obstacle');
    expect(alert.severity, 'high');
    expect(alert.message, 'Auto en ciclovía');
    expect(alert.title, contains('ciclovía'));
  });
}
