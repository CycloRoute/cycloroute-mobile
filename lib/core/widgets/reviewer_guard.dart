import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

class ReviewerGuard extends StatelessWidget {
  const ReviewerGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = appL10n(context);

    if (auth.canReviewInfrastructure) {
      return child;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accessDenied)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.insufficientRole,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
