import 'package:cyclerisk/features/infrastructure/presentation/infrastructure_analysis_copy.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('es'));

  test('a pending analysis does not say the score was already integrated', () {
    final body = analysisQualityBody(
      l10n,
      pending: true,
      quality: 'REGULAR',
    );
    final lead = analysisResultLead(l10n, pending: true);

    expect(body, isNot(contains('se integró')));
    expect(body, contains('grafo'));
    expect(lead, isNot(contains('actualizó el mapa')));
    expect(lead, contains('grafo aún no cambia'));
  });

  test('an approved analysis can say the score was integrated', () {
    final body = analysisQualityBody(
      l10n,
      pending: false,
      quality: 'REGULAR',
    );

    expect(body, contains('se integró'));
    expect(analysisResultLead(l10n, pending: false), contains('actualizó el mapa'));
  });
}
