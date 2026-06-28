import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/auth_api.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/primary_button.dart';

/// Generic OTP verification screen. It verifies the entered code against the
/// backend (for the given [purpose]) and, on success, runs [onVerified] with the
/// code so the caller can complete sign-up / password reset.
class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  /// [OtpPurpose.signup] or [OtpPurpose.reset].
  final String purpose;
  final String title;
  final String subtitle;

  /// Runs the next step with the verified code. Returns an optional error
  /// message; null = success.
  final Future<String?> Function(String code) onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.purpose,
    required this.onVerified,
    this.title = 'Verify your number',
    this.subtitle = 'Enter the 4-digit code we sent to',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _code = '';
  bool _loading = false;
  bool _error = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.length != 4) return;
    setState(() {
      _loading = true;
      _error = false;
    });
    final auth = context.read<AuthProvider>();

    // First confirm the code with the backend (does not consume it).
    final verifyError = await auth.verifyOtp(
      phone: widget.phone,
      purpose: widget.purpose,
      code: _code,
    );
    if (!mounted) return;
    if (verifyError != null) {
      setState(() {
        _loading = false;
        _error = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(verifyError)));
      return;
    }

    // Code is valid — run the caller's next step (signup / reset) with it.
    final error = await widget.onVerified(_code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final error = widget.purpose == OtpPurpose.reset
        ? await auth.requestResetOtp(widget.phone)
        : await auth.requestSignupOtp(widget.phone);
    if (!mounted) return;
    _startTimer();
    final devCode = auth.lastDevCode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ??
            (devCode != null
                ? 'A new code has been sent (demo: $devCode).'
                : 'A new code has been sent.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devCode = context.watch<AuthProvider>().lastDevCode;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeIn(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: const Icon(Icons.sms_rounded,
                      color: AppColors.primary, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: Text(widget.title,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 10),
              FadeIn(
                delay: const Duration(milliseconds: 140),
                child: Text.rich(
                  TextSpan(
                    text: '${widget.subtitle} ',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: '+91 ${widget.phone}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: OtpInput(
                  hasError: _error,
                  onChanged: (v) => setState(() {
                    _code = v;
                    _error = false;
                  }),
                  onCompleted: (_) => _verify(),
                ),
              ),
              if (devCode != null) ...[
                const SizedBox(height: 16),
                FadeIn(
                  delay: const Duration(milliseconds: 240),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.softGreenTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Demo code: $devCode',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 300),
                child: PrimaryButton(
                  label: 'Verify',
                  loading: _loading,
                  onPressed: _code.length == 4 ? _verify : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend code'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
