import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_exception.dart';
import '../../models/appointment.dart';
import '../../state/appointment_provider.dart';
import '../../state/doctor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_in.dart';
import '../doctors/doctor_detail_screen.dart';
import '../main_shell.dart';
import '../reviews/write_review_screen.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: const Text('My Appointments'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Consumer<AppointmentProvider>(
          builder: (_, provider, __) {
            final loading = provider.loading && provider.count == 0;
            return TabBarView(
              children: [
                _AppointmentList(
                  items: provider.upcoming,
                  status: AppointmentStatus.upcoming,
                  loading: loading,
                  emptyTitle: 'No upcoming visits',
                  emptyMessage:
                      'Book an appointment with a doctor and it will show up '
                      'here.',
                ),
                _AppointmentList(
                  items: provider.completed,
                  status: AppointmentStatus.completed,
                  loading: loading,
                  emptyTitle: 'Nothing completed yet',
                  emptyMessage:
                      'Your past consultations will appear here once visited.',
                ),
                _AppointmentList(
                  items: provider.cancelled,
                  status: AppointmentStatus.cancelled,
                  loading: loading,
                  emptyTitle: 'No cancellations',
                  emptyMessage: 'Appointments you cancel will be listed here.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> items;
  final AppointmentStatus status;
  final bool loading;
  final String emptyTitle;
  final String emptyMessage;

  const _AppointmentList({
    required this.items,
    required this.status,
    required this.loading,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.event_note_rounded,
        title: emptyTitle,
        message: emptyMessage,
        action: status == AppointmentStatus.upcoming
            ? FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                ),
                onPressed: () => MainShell.of(context)?.goTo(0),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Book a doctor'),
              )
            : null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => FadeIn(
        delay: Duration(milliseconds: i * 60),
        child: _AppointmentCard(appointment: items[i]),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        return AppColors.info;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.danger;
    }
  }

  void _openDoctor(BuildContext context) {
    final doctor =
        context.read<DoctorProvider>().byId(appointment.doctorId);
    if (doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Still loading doctor — please retry.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  Future<void> _markVisited(BuildContext context) async {
    try {
      await context
          .read<AppointmentProvider>()
          .markCompleted(appointment.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _cancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: const Text('Cancel appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      try {
        await context.read<AppointmentProvider>().cancel(appointment.id);
      } on ApiException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(name: a.doctorName, imageUrl: a.doctorPhotoUrl, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.doctorName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            a.status.label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
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
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.softGreenTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                _MiniInfo(
                  icon: Icons.calendar_today_rounded,
                  text: Fmt.shortDate(a.dateTime),
                ),
                Container(width: 1, height: 28, color: AppColors.mintDark),
                _MiniInfo(
                  icon: Icons.access_time_rounded,
                  text: a.slotLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        return Row(
          children: [
            Expanded(
              child: _OutlineAction(
                label: 'Cancel',
                color: AppColors.danger,
                onTap: () => _cancel(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilledAction(
                label: 'Mark visited',
                icon: Icons.check_circle_outline_rounded,
                onTap: () => _markVisited(context),
              ),
            ),
          ],
        );
      case AppointmentStatus.completed:
        return Row(
          children: [
            Expanded(
              child: _OutlineAction(
                label: 'Book again',
                color: AppColors.primary,
                onTap: () => _openDoctor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: appointment.reviewed
                  ? _DisabledAction(
                      label: 'Reviewed',
                      icon: Icons.verified_rounded,
                    )
                  : _FilledAction(
                      label: 'Write review',
                      icon: Icons.rate_review_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              WriteReviewScreen(appointment: appointment),
                        ),
                      ),
                    ),
            ),
          ],
        );
      case AppointmentStatus.cancelled:
        return _FilledAction(
          label: 'Book again',
          icon: Icons.refresh_rounded,
          onTap: () => _openDoctor(context),
        );
    }
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilledAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlineAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _DisabledAction extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DisabledAction({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.success, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
