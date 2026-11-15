import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/utils/distance_format.dart';
import 'package:cyclerisk/features/route_results/data/models/route_option.dart';
import 'package:cyclerisk/features/route_results/data/models/route_segment.dart';
import 'package:cyclerisk/features/route_results/presentation/widgets/route_detail_preview_panel.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short segments that would show as 0.0 km are hidden', () {
    final visible = visibleRouteSegments([
      const RouteSegment(
        fromIndex: 0,
        toIndex: 1,
        distanceM: 0,
        cycloScore: 0.2,
      ),
      const RouteSegment(
        fromIndex: 1,
        toIndex: 2,
        distanceM: 1200,
        cycloScore: 0.8,
      ),
    ]);

    expect(visible, hasLength(1));
    expect(visible.single.distanceM, 1200);
  });

  testWidgets('route detail shows the summary before the steps', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('es'));
    final route = RouteOption(
      routeId: 'recommended',
      distanceM: 7200,
      cycloScore: 0.67,
      durationMin: 29,
      coordinates: const [],
      why: const ['Prioriza ciclovías'],
      segments: const [
        RouteSegment(
          fromIndex: 0,
          toIndex: 1,
          distanceM: 0,
          cycloScore: 0.1,
        ),
        RouteSegment(
          fromIndex: 1,
          toIndex: 2,
          distanceM: 1200,
          cycloScore: 0.8,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: RouteDetailPreviewPanel(
              route: route,
              l10n: l10n,
              distanceFormat: DistanceFormat(
                unit: DistanceUnit.kilometers,
                l10n: l10n,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('7.2 km'), findsOneWidget);
    expect(find.text('29 min'), findsOneWidget);
    expect(find.text('67'), findsOneWidget);
    expect(find.text('Prioriza ciclovías'), findsOneWidget);
    expect(find.text('Motivo de la recomendación'), findsOneWidget);
    expect(find.text('0.0 km'), findsNothing);
    expect(find.text('1.2 km'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Motivo de la recomendación')).dy,
      lessThan(tester.getTopLeft(find.text(l10n.turnByTurnTitle)).dy),
    );
    expect(
      tester.getTopLeft(find.text(l10n.alertsAlongRouteTitle)).dy,
      lessThan(tester.getTopLeft(find.text(l10n.routeSegmentsTitle)).dy),
    );
  });
}
