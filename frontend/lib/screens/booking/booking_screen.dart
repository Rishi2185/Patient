import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/doctor.dart';
import '../../state/appointment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/slot_generator.dart';
import '../../widgets/avatar.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';
import 'patient_details_screen.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;

  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<DateTime> _dates;
  DateTime? _selectedDate;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)),
    );
    _selectedDate = _dates.firstWhere(
      _isAvailable,
      orElse: () => _dates.first,
    );
  }

  bool _isAvailable(DateTime date) {
    final wd = DateFormat('EEE').format(date); // Mon, Tue...
    return widget.doctor.availableDays.contains(wd);
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final date = _selectedDate!;
    final morning = SlotGenerator.morning(doctor, date);
    final afternoon = SlotGenerator.afternoon(doctor, date);
    final evening = SlotGenerator.evening(doctor, date);
    final available = _isAvailable(date);

    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          FadeIn(child: _DoctorStrip(doctor: doctor)),
          const SizedBox(height: 24),
          FadeIn(
            delay: const Duration(milliseconds: 80),
            child: const _Heading(
              icon: Icons.calendar_month_rounded,
              text: 'Select date',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Fmt.monthYear(date),
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final d = _dates[i];
                final selected = d == _selectedDate;
                final enabled = _isAvailable(d);
                return _DateChip(
                  date: d,
                  selected: selected,
                  enabled: enabled,
                  isToday: i == 0,
                  onTap: enabled
                      ? () => setState(() {
                            _selectedDate = d;
                            _selectedSlot = null;
                          })
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 26),
          FadeIn(
            child: const _Heading(
              icon: Icons.schedule_rounded,
              text: 'Select time slot',
            ),
          ),
          const SizedBox(height: 16),
          if (!available)
            _Unavailable(doctor: doctor)
          else ...[
            _SlotGroup(
              label: 'Morning',
              icon: Icons.wb_twilight_rounded,
              slots: morning,
              doctor: doctor,
              date: date,
              selected: _selectedSlot,
              onSelect: (s) => setState(() => _selectedSlot = s),
            ),
            _SlotGroup(
              label: 'Afternoon',
              icon: Icons.wb_sunny_rounded,
              slots: afternoon,
              doctor: doctor,
              date: date,
              selected: _selectedSlot,
              onSelect: (s) => setState(() => _selectedSlot = s),
            ),
            _SlotGroup(
              label: 'Evening',
              icon: Icons.nights_stay_rounded,
              slots: evening,
              doctor: doctor,
              date: date,
              selected: _selectedSlot,
              onSelect: (s) => setState(() => _selectedSlot = s),
            ),
          ],
        ],
      ),
      bottomSheet: _ProceedBar(
        enabled: _selectedSlot != null,
        fee: doctor.consultationFee,
        summary: _selectedSlot == null
            ? 'Select a slot to continue'
            : Fmt.dateWithSlot(date, _selectedSlot!),
        onProceed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PatientDetailsScreen(
                doctor: doctor,
                date: date,
                slot: _selectedSlot!,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorStrip extends StatelessWidget {
  final Doctor doctor;

  const _DoctorStrip({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softGreenTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Avatar(name: doctor.name, imageUrl: doctor.photoUrl, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty.name,
                  style: TextStyle(
                    color: doctor.specialty.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Heading({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool enabled;
  final bool isToday;
  final VoidCallback? onTap;

  const _DateChip({
    required this.date,
    required this.selected,
    required this.enabled,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.white
        : enabled
            ? AppColors.textPrimary
            : AppColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.fast,
        width: 62,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: selected ? AppColors.softShadow : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : Fmt.weekday(date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Fmt.dayNum(date),
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: color,
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> slots;
  final Doctor doctor;
  final DateTime date;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SlotGroup({
    required this.label,
    required this.icon,
    required this.slots,
    required this.doctor,
    required this.date,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();
    final appointments = context.watch<AppointmentProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((slot) {
            final booked =
                appointments.isSlotBooked(doctor.id, date, slot);
            final isSelected = selected == slot;
            return _SlotChip(
              label: slot,
              selected: isSelected,
              booked: booked,
              onTap: booked ? null : () => onSelect(slot),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool booked;
  final VoidCallback? onTap;

  const _SlotChip({
    required this.label,
    required this.selected,
    required this.booked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.fast,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : booked
                  ? AppColors.scaffold
                  : AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            decoration: booked ? TextDecoration.lineThrough : null,
            color: selected
                ? Colors.white
                : booked
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  final Doctor doctor;

  const _Unavailable({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy_rounded,
              color: AppColors.primary, size: 36),
          const SizedBox(height: 12),
          const Text(
            'Not available on this day',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${doctor.name.split(' ').take(2).join(' ')} consults on '
            '${doctor.availableDays.join(', ')}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProceedBar extends StatelessWidget {
  final bool enabled;
  final int fee;
  final String summary;
  final VoidCallback onProceed;

  const _ProceedBar({
    required this.enabled,
    required this.fee,
    required this.summary,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Proceed to Pay ${Fmt.rupees(fee)}',
                onPressed: enabled ? onProceed : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
