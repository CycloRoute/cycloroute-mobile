import 'package:flutter_test/flutter_test.dart';

import 'package:cyclerisk/app/app.dart';

void main() {
  testWidgets('CycloRoute app renders auth entry', (tester) async {
    await tester.pumpWidget(const CycloRouteApp());
    await tester.pumpAndSettle();

    expect(find.text('CycloRoute'), findsOneWidget);
  });
}
