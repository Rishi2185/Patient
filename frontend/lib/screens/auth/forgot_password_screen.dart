import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';
import 'otp_verification_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phone = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final err = Validators.phone(_phone.text);
    setState(() => _error = err);
    if (err != null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.phoneExists(_phone.text.trim())) {
      setState(() => _error = 'No account found for this number.');
      return;
    }

    setState(() => _loading = true);
    await auth.sendOtp(_phone.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);

    final phone = _phone.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phone: phone,
          title: 'Verify it’s you',
          onVerified: () async {
            if (!mounted) return null;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(phone: phone),
              ),
            );
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
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
                  child: const Icon(Icons.lock_reset_rounded,
                      color: AppColors.primary, size: 38),
                ),
              ),
              const SizedBox(height: 24),
              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: Text('Reset your password',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 10),
              FadeIn(
                delay: const Duration(milliseconds: 140),
                child: const Text(
                  'Enter your registered mobile number and we’ll send you a '
                  'verification code to reset your password.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: AppTextField(
                  label: 'Phone number',
                  hint: '10-digit mobile number',
                  controller: _phone,
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  errorText: _error,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
              ),
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 260),
                child: PrimaryButton(
                  label: 'Send Code',
                  loading: _loading,
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
