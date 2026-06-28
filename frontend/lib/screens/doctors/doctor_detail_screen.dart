import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/doctor.dart';
import '../../state/hospital_provider.dart';
import '../../state/review_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/avatar.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/section_header.dart';
import '../booking/booking_screen.dart';
import '../hospitals/hospital_detail_screen.dart';
import '../reviews/doctor_reviews_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReviewProvider>().loadForDoctor(widget.doctor.id);
      context.read<HospitalProvider>().load(); // no-op if already loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.reviewsForDoctor(doctor.id);
    final aggRating = reviewProvider.aggregateRating(doctor);
    final aggCount = reviewProvider.aggregateCount(doctor);
    final hospital = context.watch<HospitalProvider>().byId(doctor.hospitalId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _Header(doctor: doctor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeIn(
                    child: _StatsRow(
                      doctor: doctor,
                      rating: aggRating,
                      reviews: aggCount,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeIn(
                    delay: const Duration(milliseconds: 80),
                    child: const _Heading('About'),
                  ),
                  const SizedBox(height: 8),
                  FadeIn(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      doctor.about,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeIn(
                    delay: const Duration(milliseconds: 160),
                    child: const _Heading('Consultation timings'),
                  ),
                  const SizedBox(height: 12),
                  FadeIn(
                    delay: const Duration(milliseconds: 200),
                    child: _InfoCard(
                      icon: Icons.schedule_rounded,
                      title: doctor.consultTimings,
                      subtitle: doctor.availableDays.join(' · '),
                      trailing: doctor.availableToday
                          ? _AvailableBadge()
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeIn(
                    delay: const Duration(milliseconds: 220),
                    child: _InfoCard(
                      icon: Icons.translate_rounded,
                      title: 'Speaks',
                      subtitle: doctor.languages.join(', '),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Hospital
                  if (hospital != null) ...[
                    FadeIn(
                      delay: const Duration(milliseconds: 260),
                      child: const _Heading('Hospital'),
                    ),
                    const SizedBox(height: 12),
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                HospitalDetailScreen(hospital: hospital),
                          ),
                        ),
                        child: _InfoCard(
                          icon: Icons.local_hospital_rounded,
                          title: hospital.name,
                          subtitle: '${hospital.address}, ${hospital.city}',
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else if (doctor.hospitalName.isNotEmpty) ...[
                    FadeIn(
                      delay: const Duration(milliseconds: 260),
                      child: const _Heading('Hospital'),
                    ),
                    const SizedBox(height: 12),
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: _InfoCard(
                        icon: Icons.local_hospital_rounded,
                        title: doctor.hospitalName,
                        subtitle: 'Affiliated hospital',
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Reviews
                  FadeIn(
                    delay: const Duration(milliseconds: 340),
                    child: SectionHeader(
                      title: 'Reviews ($aggCount)',
                      actionLabel: reviews.isEmpty ? null : 'See all',
                      onAction: reviews.isEmpty
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DoctorReviewsScreen(doctor: doctor),
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RatingSummary(rating: aggRating, count: aggCount),
                  const SizedBox(height: 14),
                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No reviews yet. Be the first to share your '
                        'experience after a visit.',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    )
                  else
                    ...reviews.take(2).map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReviewTile(review: r),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _BookingBar(doctor: doctor),
    );
  }
}

class _Header extends StatelessWidget {
  final Doctor doctor;

  const _Header({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: const EdgeInsets.only(top: 90, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'doc-${doctor.id}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Avatar(
                name: doctor.name,
                imageUrl: doctor.photoUrl,
                size: 96,
                background: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            doctor.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(doctor.specialty.icon, color: Colors.white, size: 15),
                const SizedBox(width: 6),
                Text(
                  doctor.specialty.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            doctor.qualifications,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Doctor doctor;
  final double rating;
  final int reviews;

  const _StatsRow({
    required this.doctor,
    required this.rating,
    required this.reviews,
  });

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
          _Stat(
            value: '${doctor.experienceYears}+',
            label: 'Years exp.',
            icon: Icons.workspace_premium_rounded,
          ),
          _divider(),
          _Stat(
            value: Fmt.compact(doctor.patientsServed),
            label: 'Patients',
            icon: Icons.groups_rounded,
          ),
          _divider(),
          _Stat(
            value: rating.toStringAsFixed(1),
            label: '$reviews reviews',
            icon: Icons.star_rounded,
            iconColor: AppColors.star,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.divider,
      );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
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

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _AvailableBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Today',
        style: TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double rating;
  final int count;

  const _RatingSummary({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGreenTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              RatingStars(rating: rating, size: 15),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Based on $count verified patient reviews. Patients value the '
              'clear explanations and caring approach.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  final Doctor doctor;

  const _BookingBar({required this.doctor});

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
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Consultation fee',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Fmt.rupees(doctor.consultationFee),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: PrimaryButton(
                  label: 'Book Appointment',
                  icon: Icons.calendar_month_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(doctor: doctor),
                    ),
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
