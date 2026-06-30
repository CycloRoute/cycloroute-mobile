import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';

class ReviewerGuard extends StatelessWidget {
  const ReviewerGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = appL10n(context);

    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLoggedIn || !auth.canModerateObstacles) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.accessDenied)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              auth.isLoggedIn
                  ? l10n.insufficientRole
                  : l10n.pleaseSignInAgain,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return child;
  }
}
