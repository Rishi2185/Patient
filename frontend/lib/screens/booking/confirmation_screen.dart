import 'package:flutter/material.dart';

import '../../models/appointment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/avatar.dart';
import '../../widgets/primary_button.dart';
import '../main_shell.dart';

class ConfirmationScreen extends StatefulWidget {
  final Appointment appointment;

  const ConfirmationScreen({super.key, required this.appointment});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _check = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final AnimationController _content = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _content.forward();
    });
  }

  @override
  void dispose() {
    _check.dispose();
    _content.dispose();
    super.dispose();
  }

  void _goToAppointments() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
      (route) => false,
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _check,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.elevatedShadow,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 64),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _content,
                child: Column(
                  children: [
                    Text(
                      'Appointment confirmed!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your booking has been successfully placed. A '
                      'confirmation has been sent to your phone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _content,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: _content, curve: Curves.easeOut)),
                  child: _TicketCard(appointment: a),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _content,
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'View My Appointments',
                      icon: Icons.calendar_month_rounded,
                      onPressed: _goToAppointments,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _goHome,
                      child: const Text('Back to home'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Appointment appointment;

  const _TicketCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Avatar(name: a.doctorName, imageUrl: a.doctorPhotoUrl, size: 54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.specialtyName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: _DashedDivider(),
          ),
          _row(Icons.calendar_today_rounded, 'Date',
              Fmt.shortDate(a.dateTime)),
          const SizedBox(height: 12),
          _row(Icons.access_time_rounded, 'Time', a.slotLabel),
          const SizedBox(height: 12),
          _row(Icons.local_hospital_rounded, 'Hospital', a.hospitalName),
          const SizedBox(height: 12),
          _row(Icons.receipt_long_rounded, 'Amount paid',
              Fmt.rupees(a.fee)),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textTertiary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 5.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1.4,
              color: AppColors.border,
            ),
          ),
        );
      },
    );
  }
}
