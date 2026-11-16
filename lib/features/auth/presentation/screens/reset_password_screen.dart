import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/localize_api_error.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/auth/presentation/widgets/auth_flow_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
    this.resendCooldown = const Duration(minutes: 5),
  });

  final String? initialEmail;
  final Duration resendCooldown;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

String formatResendCountdown(Duration remaining) {
  final totalSeconds = remaining.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  Timer? _resendTicker;
  late int _resendSecondsLeft;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _codeController = TextEditingController();
    _passwordController = TextEditingController();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTicker?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendSecondsLeft = widget.resendCooldown.inSeconds;
    _resendTicker?.cancel();
    if (_resendSecondsLeft <= 0) return;
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendSecondsLeft > 0) {
          _resendSecondsLeft -= 1;
        }
      });
      if (_resendSecondsLeft == 0) {
        _resendTicker?.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    final l10n = appL10n(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = l10n.fillAllFields);
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final message = await context.read<AuthProvider>().forgotPassword(email);

    if (!mounted) return;

    if (message == null) {
      final lastError = context.read<AuthProvider>().lastApiError;
      setState(() {
        _isResending = false;
        _errorMessage = localizeAuthError(l10n, lastError) ?? l10n.resetFailed;
      });
      return;
    }

    setState(() => _isResending = false);
    _startResendCooldown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.resendResetCodeSent)),
    );
  }

  Future<void> _submit() async {
    final l10n = appL10n(context);
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || code.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = l10n.fillAllFieldsReset);
      return;
    }

    if (code.length != 6) {
      setState(() => _errorMessage = l10n.codeMustBeSixDigits);
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = l10n.passwordMinLength);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<AuthProvider>().resetPassword(
      emailAddress: email,
      code: code,
      newPassword: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      final lastError = context.read<AuthProvider>().lastApiError;
      setState(
        () => _errorMessage =
            localizeAuthError(l10n, lastError) ?? l10n.resetFailed,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.passwordUpdatedSignIn)),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => route.settings.name == AppRoutes.authEntry,
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
                  icon: Icons.verified_user_outlined,
                  title: l10n.enterCodeFromEmail,
                  subtitle: l10n.resetCodeHint,
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
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _codeController,
                        hintText: l10n.sixDigitCode,
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        counterText: '',
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: l10n.newPassword,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AuthPrimaryButton(
                        label: l10n.updatePassword,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 16),
                      if (_resendSecondsLeft > 0)
                        Text(
                          l10n.resendCodeWait(
                            formatResendCountdown(
                              Duration(seconds: _resendSecondsLeft),
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        )
                      else
                        OutlinedButton(
                          onPressed: _isResending || _isLoading
                              ? null
                              : _resendCode,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : Text(l10n.resendResetCode),
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
