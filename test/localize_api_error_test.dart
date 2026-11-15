import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/models/location_access_status.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/features/shared/widgets/location_permission_banner.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('es'));

  test('registration errors stay in Spanish and stay distinct', () {
    expect(
      localizeApiError(
        l10n,
        const ApiException(
          'Could not register user in Supabase Auth',
          detail: 'Unable to validate email address: invalid format',
        ),
      ),
      l10n.invalidEmailAddress,
    );

    expect(
      localizeApiError(
        l10n,
        const ApiException(
          'Could not register user in Supabase Auth',
          detail: 'A user with this email address has already been registered',
        ),
      ),
      l10n.emailAlreadyRegistered,
    );

    expect(
      localizeApiError(
        l10n,
        const ApiException('Could not register user in Supabase Auth'),
      ),
      l10n.registrationFailed,
    );
  });

  test('an unreachable route uses the Spanish empty-result message', () {
    expect(
      localizeApiError(
        l10n,
        const ApiException(
          'No feasible route found between origin and destination',
        ),
      ),
      'No se encontraron opciones de ruta para esos lugares.',
    );
  });

  test('a failed preference save does not show the generic API error', () {
    expect(
      localizePreferenceSaveError(l10n, ApiException.connectFailed()),
      l10n.couldNotUpdatePreference,
    );
    expect(
      localizePreferenceSaveError(l10n, null),
      l10n.couldNotUpdatePreference,
    );
  });

  test('a denied location banner uses the manual-search copy', () {
    final copy = locationPermissionBannerCopy(
      l10n,
      LocationAccessStatus.denied,
    );

    expect(copy.title, 'Ubicación aún desactivada');
    expect(
      copy.message,
      'Sin ubicación puedes buscar rutas manualmente, pero la navegación y tu posición en el mapa no funcionarán.',
    );
  });
}
