import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;

  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pw = Validators.password(_password.text);
    final c = Validators.confirmPassword(_confirm.text, _password.text);
    setState(() {
      _passwordError = pw;
      _confirmError = c;
    });
    if (pw != null || c != null) return;

    setState(() => _loading = true);
    final error = await context.read<AuthProvider>().resetPassword(
          phone: widget.phone,
          newPassword: _password.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully. Please sign in.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeIn(
                child: Text('Create a new password',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 10),
              FadeIn(
                delay: const Duration(milliseconds: 120),
                child: const Text(
                  'Choose a strong password you don’t use elsewhere.',
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
                  label: 'New password',
                  hint: 'At least 8 characters',
                  controller: _password,
                  prefixIcon: Icons.lock_rounded,
                  obscure: true,
                  errorText: _passwordError,
                  onChanged: (v) => setState(
                      () => _passwordError = Validators.password(v)),
                ),
              ),
              const SizedBox(height: 16),
              FadeIn(
                delay: const Duration(milliseconds: 220),
                child: AppTextField(
                  label: 'Confirm password',
                  hint: 'Re-enter new password',
                  controller: _confirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscure: true,
                  errorText: _confirmError,
                  onChanged: (v) => setState(() => _confirmError =
                      Validators.confirmPassword(v, _password.text)),
                ),
              ),
              const SizedBox(height: 28),
              FadeIn(
                delay: const Duration(milliseconds: 280),
                child: PrimaryButton(
                  label: 'Reset Password',
                  loading: _loading,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
