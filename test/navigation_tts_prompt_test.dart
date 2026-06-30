import 'package:flutter_test/flutter_test.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_tts_prompt.dart';

void main() {
  group('NavigationTtsPrompt', () {
    test('uses backend instruction as-is', () {
      final prompt = NavigationTtsPrompt.build(
        instruction: 'Gira a la izquierda en Jirón Lampa',
      );

      expect(prompt, 'Gira a la izquierda en Jirón Lampa');
    });

    test('prefixes live distance without rewriting instruction', () {
      final prompt = NavigationTtsPrompt.build(
        instruction: 'Gira a la izquierda en Jirón Lampa',
        distanceM: 120,
        distanceFormatter: (meters) => 'En $meters metros',
      );

      expect(
        prompt,
        'En 120 metros, Gira a la izquierda en Jirón Lampa',
      );
    });

    test('handles empty name — instruction only', () {
      final prompt = NavigationTtsPrompt.build(
        instruction: 'Continúa recto',
        distanceM: 22,
        distanceFormatter: (meters) => 'En $meters metros',
      );

      expect(prompt, 'En 22 metros, Continúa recto');
    });

    test('announces approach buckets as rider gets closer', () {
      final announced = <int>{};

      expect(
        NavigationTtsPrompt.nextApproachBucket(
          distanceM: 120,
          announcedBuckets: announced,
        ),
        250,
      );

      announced.add(250);
      expect(
        NavigationTtsPrompt.nextApproachBucket(
          distanceM: 95,
          announcedBuckets: announced,
        ),
        100,
      );
    });

    test('announces only the nearest bucket when already close', () {
      final announced = <int>{};

      expect(
        NavigationTtsPrompt.nextApproachBucket(
          distanceM: 30,
          announcedBuckets: announced,
        ),
        30,
      );

      announced.add(30);
      expect(
        NavigationTtsPrompt.nextApproachBucket(
          distanceM: 30,
          announcedBuckets: announced,
        ),
        isNull,
      );
    });
  });
}
