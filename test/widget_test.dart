import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cyclerisk/features/auth/presentation/screens/auth_entry_screen.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

void main() {
  testWidgets('Auth entry screen renders CycloRoute branding', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthEntryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CycloRoute'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}
