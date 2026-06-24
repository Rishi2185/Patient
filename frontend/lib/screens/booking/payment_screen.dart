import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../data/mock_data.dart';
import '../../state/appointment_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/slot_generator.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';
import 'confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime date;
  final String slot;

  const PaymentScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.slot,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.upi;
  bool _processing = false;

  static const int _platformFee = 49;

  int get _total => widget.doctor.consultationFee + _platformFee;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final hospital = MockData.hospitalById(widget.doctor.hospitalId);
    final appt = Appointment(
      id: 'apt_${DateTime.now().microsecondsSinceEpoch}',
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.name,
      doctorPhotoUrl: widget.doctor.photoUrl,
      specialtyName: widget.doctor.specialty.name,
      hospitalName: hospital.name,
      dateTime: SlotGenerator.toDateTime(widget.date, widget.slot),
      slotLabel: widget.slot,
      fee: _total,
      paymentMethod: _method,
    );
    await context.read<AppointmentProvider>().book(appt);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(appointment: appt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Payment')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
            children: [
              FadeIn(child: _buildSummaryCard()),
              const SizedBox(height: 24),
              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: const _SectionTitle('Payment method'),
              ),
              const SizedBox(height: 12),
              FadeIn(
                delay: const Duration(milliseconds: 120),
                child: _PaymentOption(
                  method: PaymentMethod.upi,
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'UPI',
                  subtitle: 'GPay, PhonePe, Paytm & more',
                  selected: _method == PaymentMethod.upi,
                  onTap: () => setState(() => _method = PaymentMethod.upi),
                  child: const _UpiForm(),
                ),
              ),
              const SizedBox(height: 12),
              FadeIn(
                delay: const Duration(milliseconds: 160),
                child: _PaymentOption(
                  method: PaymentMethod.card,
                  icon: Icons.credit_card_rounded,
                  title: 'Credit / Debit Card',
                  subtitle: 'Visa, Mastercard, RuPay',
                  selected: _method == PaymentMethod.card,
                  onTap: () => setState(() => _method = PaymentMethod.card),
                  child: const _CardForm(),
                ),
              ),
              const SizedBox(height: 12),
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: _PaymentOption(
                  method: PaymentMethod.wallet,
                  icon: Icons.savings_rounded,
                  title: 'Aarvy Wallet',
                  subtitle: 'Balance: ₹2,500',
                  selected: _method == PaymentMethod.wallet,
                  onTap: () => setState(() => _method = PaymentMethod.wallet),
                ),
              ),
              const SizedBox(height: 20),
              const FadeIn(
                delay: Duration(milliseconds: 240),
                child: _SecureNote(),
              ),
            ],
          ),
          bottomSheet: _PayBar(
            total: _total,
            onPay: _pay,
          ),
        ),
        if (_processing) const _ProcessingOverlay(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _row('Consultation', widget.doctor.name),
          const SizedBox(height: 10),
          _row('Date & time',
              Fmt.dateWithSlot(widget.date, widget.slot)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          _amount('Consultation fee', widget.doctor.consultationFee),
          const SizedBox(height: 8),
          _amount('Platform fee', _platformFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total payable',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                Fmt.rupees(_total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _amount(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
        Text(
          Fmt.rupees(value),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final PaymentMethod method;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  const _PaymentOption({
    required this.method,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.fast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.softGreenTint : AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.mint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: selected ? Colors.white : AppColors.primary,
                      size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _Radio(selected: selected),
              ],
            ),
            if (selected && child != null) ...[
              const SizedBox(height: 16),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;

  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTheme.fast,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.textTertiary,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _UpiForm extends StatelessWidget {
  const _UpiForm();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'yourname@upi',
        prefixIcon: Icon(Icons.alternate_email_rounded),
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  const _CardForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          decoration: const InputDecoration(
            hintText: 'Card number',
            prefixIcon: Icon(Icons.credit_card_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(hintText: 'MM / YY'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(hintText: 'CVV'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecureNote extends StatelessWidget {
  const _SecureNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          'Payments are secure & encrypted · Demo only',
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _PayBar extends StatelessWidget {
  final int total;
  final VoidCallback onPay;

  const _PayBar({required this.total, required this.onPay});

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
          child: PrimaryButton(
            label: 'Pay ${Fmt.rupees(total)}',
            icon: Icons.lock_rounded,
            onPressed: onPay,
          ),
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 46,
                height: 46,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Processing payment…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Please don’t close the app',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
