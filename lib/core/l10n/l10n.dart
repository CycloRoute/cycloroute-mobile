import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/utils/distance_format.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

AppLocalizations appL10n(BuildContext context) {
  final value = AppLocalizations.of(context);
  assert(value != null, 'AppLocalizations not found in context');
  return value!;
}

/// Formats distances using the user's unit preference (km/mi).
/// Call from [build]; rebuilds when units change in Settings.
DistanceFormat distanceFormatOf(BuildContext context) {
  final unit = context.watch<NavigationPreferencesProvider>().distanceUnit;
  return DistanceFormat(unit: unit, l10n: appL10n(context));
}
