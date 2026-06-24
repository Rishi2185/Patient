import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/primary_button.dart';

/// Generic OTP verification screen. On a correct code it runs [onVerified],
/// which performs the next step (registration, reset, etc.).
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String title;
  final String subtitle;

  /// Returns an optional error message; null = success.
  final Future<String?> Function() onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
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
    final auth = context.read<AuthProvider>();
    if (!auth.verifyOtp(_code)) {
      setState(() => _error = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect code. Try the demo OTP 1234.')),
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = false;
    });
    final error = await widget.onVerified();
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _resend() async {
    await context.read<AuthProvider>().sendOtp(widget.phone);
    _startTimer();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A new code has been sent (demo: 1234).')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    child: const Text(
                      'Demo OTP is 1234',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
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
