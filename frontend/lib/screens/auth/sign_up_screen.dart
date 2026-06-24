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
import '../main_shell.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _usernameError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;
  PasswordStrength _strength = PasswordStrength.empty;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _validate() {
    final u = Validators.username(_username.text);
    final p = Validators.phone(_phone.text);
    final pw = Validators.password(_password.text);
    final c = Validators.confirmPassword(_confirm.text, _password.text);
    setState(() {
      _usernameError = u;
      _phoneError = p;
      _passwordError = pw;
      _confirmError = c;
    });
    return u == null && p == null && pw == null && c == null;
  }

  Future<void> _continue() async {
    if (!_validate()) return;
    final auth = context.read<AuthProvider>();

    if (auth.phoneExists(_phone.text.trim())) {
      setState(() => _phoneError = 'An account with this number already exists.');
      return;
    }

    setState(() => _loading = true);
    await auth.sendOtp(_phone.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phone: _phone.text.trim(),
          title: 'Verify your number',
          onVerified: () async {
            final error = await auth.signUp(
              username: _username.text.trim(),
              phone: _phone.text.trim(),
              password: _password.text,
            );
            if (error != null) return error;
            await auth.signIn(
              phone: _phone.text.trim(),
              password: _password.text,
              rememberMe: true,
            );
            if (!mounted) return null;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
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
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeIn(
                child: Text(
                  'Let’s get you started',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              FadeIn(
                delay: const Duration(milliseconds: 120),
                child: const Text(
                  'Create an account to book and track appointments.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 180),
                child: AppTextField(
                  label: 'Username',
                  hint: 'Your name',
                  controller: _username,
                  prefixIcon: Icons.person_rounded,
                  textInputAction: TextInputAction.next,
                  errorText: _usernameError,
                  onChanged: (v) => setState(
                      () => _usernameError = Validators.username(v)),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 220),
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
                  textInputAction: TextInputAction.next,
                  errorText: _phoneError,
                  onChanged: (v) =>
                      setState(() => _phoneError = Validators.phone(v)),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 260),
                child: AppTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  controller: _password,
                  prefixIcon: Icons.lock_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  errorText: _passwordError,
                  onChanged: (v) => setState(() {
                    _strength = scorePassword(v);
                    _passwordError = Validators.password(v);
                    if (_confirm.text.isNotEmpty) {
                      _confirmError =
                          Validators.confirmPassword(_confirm.text, v);
                    }
                  }),
                ),
              ),
              if (_strength != PasswordStrength.empty) ...[
                const SizedBox(height: 4),
                _PasswordStrengthBar(strength: _strength),
              ],
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 300),
                child: AppTextField(
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  controller: _confirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  errorText: _confirmError,
                  suffix: _confirm.text.isNotEmpty &&
                          _confirm.text == _password.text
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.success)
                      : null,
                  onChanged: (v) => setState(() => _confirmError =
                      Validators.confirmPassword(v, _password.text)),
                ),
              ),
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 340),
                child: PrimaryButton(
                  label: 'Create Account',
                  loading: _loading,
                  onPressed: _continue,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;

  const _PasswordStrengthBar({required this.strength});

  Color get _color {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.danger;
      case PasswordStrength.fair:
        return AppColors.warning;
      case PasswordStrength.good:
        return AppColors.primaryBright;
      case PasswordStrength.strong:
        return AppColors.success;
      case PasswordStrength.empty:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: strength.progress),
                duration: AppTheme.fast,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strength.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
