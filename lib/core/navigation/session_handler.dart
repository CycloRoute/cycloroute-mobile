import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class SessionHandler {
  SessionHandler._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void handleSessionExpired() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = appL10n(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(l10n.sessionExpired),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) =>
          route.settings.name == AppRoutes.authEntry ||
          route.settings.name == AppRoutes.login,
    );
  }
}
