import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/features/auth/presentation/widgets/auth_flow_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = appL10n(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = l10n.fillAllFields);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final message = await context.read<AuthProvider>().forgotPassword(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (message == null) {
      final lastError = context.read<AuthProvider>().lastApiError;
      setState(
        () => _errorMessage =
            localizeAuthError(l10n, lastError) ?? l10n.resetFailed,
      );
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dialogL10n = appL10n(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(dialogL10n.checkYourEmail),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogL10n.continueButton),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.resetPassword,
      arguments: email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appL10n(context);

    return AuthGradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
                AuthPageHeader(
                  icon: Icons.lock_reset_rounded,
                  title: l10n.resetYourPassword,
                  subtitle: l10n.forgotPasswordHint,
                ),
                const SizedBox(height: 22),
                AuthFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        AuthErrorBanner(message: _errorMessage!),
                        const SizedBox(height: 14),
                      ],
                      AuthTextField(
                        controller: _emailController,
                        hintText: l10n.emailAddress,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      AuthPrimaryButton(
                        label: l10n.sendResetCode,
                        icon: Icons.mail_outline_rounded,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
