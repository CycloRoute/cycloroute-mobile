import 'package:cyclerisk/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the resend countdown as minutes and seconds', () {
    expect(formatResendCountdown(const Duration(minutes: 5)), '5:00');
    expect(formatResendCountdown(const Duration(seconds: 9)), '0:09');
  });

  testWidgets('the resend button appears when the five-minute wait ends', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResetPasswordScreen(resendCooldown: Duration(seconds: 2)),
      ),
    );

    expect(find.textContaining('Si el código aún no llega'), findsOneWidget);
    expect(find.textContaining('0:02'), findsOneWidget);
    expect(find.text('Reenviar código'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('0:01'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Reenviar código'), findsOneWidget);
    expect(find.textContaining('Si el código aún no llega'), findsNothing);
  });
}
