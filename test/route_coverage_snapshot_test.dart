import 'package:cyclerisk/features/route_results/data/models/route_list_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses covered_areas instead of treating the payload as a point list', () {
    final snapshot = RouteCoverageSnapshot.fromDecoded({
      'covered_areas': [
        {
          'id': 'arequipa',
          'name': 'Av. Arequipa',
          'points': 12,
          'bbox': {
            'south': -12.12,
            'west': -77.04,
            'north': -12.08,
            'east': -77.02,
          },
        },
      ],
      'total_areas': 1,
    });

    expect(snapshot.areas, hasLength(1));
    expect(snapshot.areas.first.name, 'Av. Arequipa');
    expect(snapshot.areas.first.south, -12.12);
    expect(snapshot.areas.first.north, -12.08);
    expect(snapshot.areas.first.west, -77.04);
    expect(snapshot.areas.first.east, -77.02);
  });

  test('an object without areas is empty coverage, not a silent point list', () {
    final snapshot = RouteCoverageSnapshot.fromDecoded({
      'covered_areas': [],
      'total_areas': 0,
    });

    expect(snapshot.isEmpty, isTrue);
  });
}
