import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/appointment_provider.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/fade_in.dart';
import '../auth/sign_in_screen.dart';
import '../main_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to book visits.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    context.read<AppointmentProvider>().clear();
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final apptCount = context.watch<AppointmentProvider>().count;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FadeIn(child: _Header(name: user?.username ?? 'Patient', phone: user?.phone ?? '')),
            const SizedBox(height: 16),
            FadeIn(
              delay: const Duration(milliseconds: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsCard(appointments: apptCount),
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(milliseconds: 140),
              child: _MenuGroup(
                title: 'Account',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit profile',
                    onTap: () => _toast(context, 'Edit profile (demo)'),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'My appointments',
                    onTap: () => MainShell.of(context)?.goTo(1),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Saved doctors',
                    onTap: () => _toast(context, 'No saved doctors yet'),
                  ),
                  _MenuItem(
                    icon: Icons.payment_rounded,
                    label: 'Payment methods',
                    onTap: () => _toast(context, 'Payment methods (demo)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: _MenuGroup(
                title: 'Preferences & support',
                items: [
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () => _toast(context, 'Notification settings (demo)'),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & support',
                    onTap: () => _toast(context, 'Help center (demo)'),
                  ),
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    label: 'Privacy & terms',
                    onTap: () => _toast(context, 'Privacy policy (demo)'),
                  ),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About Aarvy',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Aarvy',
                      applicationVersion: '1.0.0 (demo)',
                      applicationLegalese:
                          'A patient-friendly appointment booking demo.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger, width: 1.3),
                ),
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Aarvy · v1.0.0 demo',
                style: TextStyle(fontSize: 12.5, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String phone;

  const _Header({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Avatar(name: name, size: 88, background: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phone.isEmpty ? '' : '+91 $phone',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int appointments;

  const _StatsCard({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _stat('$appointments', 'Appointments', Icons.event_available_rounded),
          _divider(),
          _stat('100%', 'Verified', Icons.verified_user_rounded),
          _divider(),
          _stat('Gold', 'Member', Icons.workspace_premium_rounded),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 34, color: AppColors.divider);

  Widget _stat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i != items.length - 1)
                    const Divider(height: 1, indent: 60),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
