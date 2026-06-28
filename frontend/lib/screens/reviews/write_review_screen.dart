import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../state/appointment_provider.dart';
import '../../state/review_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';

class WriteReviewScreen extends StatefulWidget {
  final Appointment appointment;

  const WriteReviewScreen({super.key, required this.appointment});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _submitting = false;

  static const _labels = {
    0: 'Tap a star to rate',
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very good',
    5: 'Excellent',
  };

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    setState(() => _submitting = true);
    final reviews = context.read<ReviewProvider>();
    final appointments = context.read<AppointmentProvider>();

    // The backend derives the patient from the token and (via appointmentId)
    // marks the appointment as reviewed.
    final error = await reviews.submitReview(
      doctorId: widget.appointment.doctorId,
      rating: _rating,
      comment: _comment.text.trim().isEmpty
          ? 'Had a good experience.'
          : _comment.text.trim(),
      appointmentId: widget.appointment.id,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    await appointments.markReviewed(widget.appointment.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks! Your review has been posted.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    return Scaffold(
      appBar: AppBar(title: const Text('Write a review')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          FadeIn(
            child: Column(
              children: [
                Avatar(
                  name: a.doctorName,
                  imageUrl: a.doctorPhotoUrl,
                  size: 80,
                ),
                const SizedBox(height: 14),
                Text(
                  a.doctorName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  a.specialtyName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeIn(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'How was your consultation?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 18),
          FadeIn(
            delay: const Duration(milliseconds: 140),
            child: RatingInput(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _labels[_rating]!,
                key: ValueKey(_rating),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _rating == 0
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeIn(
            delay: const Duration(milliseconds: 180),
            child: const Text(
              'Share your experience',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeIn(
            delay: const Duration(milliseconds: 220),
            child: TextField(
              controller: _comment,
              maxLines: 5,
              maxLength: 300,
              decoration: InputDecoration(
                hintText:
                    'What did you like? Was the doctor helpful and clear?',
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Submit Review',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
