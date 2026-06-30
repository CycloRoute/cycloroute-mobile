import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_resume_service.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_session_controller.dart';

enum NavigationResumeResult { none, resumed, sessionEnded, deferred }

class NavigationResumeCoordinator {
  NavigationResumeCoordinator._();

  static bool _promptShownThisLaunch = false;

  static Future<NavigationResumeResult> presentIfNeeded(
    BuildContext context,
  ) async {
    if (_promptShownThisLaunch) {
      return NavigationResumeResult.none;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      return NavigationResumeResult.none;
    }

    final accessToken = auth.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return NavigationResumeResult.none;
    }

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.navigation) {
      return NavigationResumeResult.none;
    }

    if (context.read<NavigationSessionController>().isSessionActive) {
      return NavigationResumeResult.none;
    }

    final resumeService = NavigationResumeService();
    final args = await resumeService.tryBuildResumeArgs(
      accessToken: accessToken,
    );
    if (args == null || !context.mounted) {
      return NavigationResumeResult.none;
    }

    _promptShownThisLaunch = true;
    final l10n = appL10n(context);
    final destinationLabel =
        args.destinationLabel?.trim().isNotEmpty == true
        ? args.destinationLabel!
        : l10n.destination;

    final choice = await showDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resumeNavigationTitle),
        content: Text(l10n.resumeNavigationMessage(destinationLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.endRoute),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.resumeNavigation),
          ),
        ],
      ),
    );

    if (!context.mounted) {
      return NavigationResumeResult.none;
    }

    if (choice == true) {
      await Navigator.of(context).pushNamed(
        AppRoutes.navigation,
        arguments: args,
      );
      return NavigationResumeResult.resumed;
    }

    if (choice == false) {
      await context.read<NavigationSessionController>().cancelNavigation();
      return NavigationResumeResult.sessionEnded;
    }

    return NavigationResumeResult.deferred;
  }
}
