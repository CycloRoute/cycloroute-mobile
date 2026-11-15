import 'package:cyclerisk/features/infrastructure/data/models/infrastructure_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analysis and the admin queue show the same rounded score', () {
    final json = {
      'id': 'capture-1',
      'score': 56.4,
      'quality': 'REGULAR',
      'latitude': -12.1,
      'longitude': -77.03,
      'status': 'pending',
      'detections': [],
      'image_url': '',
      'graph_update': {
        'applied': false,
        'edges_updated': 0,
        'radius_m': 0,
        'nearest_edge_distance_m': 0,
      },
    };

    final analysis = InfrastructureAnalysisResult.fromJson(json);
    final queued = InfrastructureMapPoint.fromJson(json);

    expect(analysis.score, 56);
    expect(queued.score, analysis.score);
  });
}
