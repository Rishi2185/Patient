import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/doctor.dart';
import '../../state/review_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/review_tile.dart';

class DoctorReviewsScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorReviewsScreen({super.key, required this.doctor});

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReviewProvider>().loadForDoctor(widget.doctor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final provider = context.watch<ReviewProvider>();
    final reviews = provider.reviewsForDoctor(doctor.id);
    final rating = provider.aggregateRating(doctor);
    final count = provider.aggregateCount(doctor);
    final loading = provider.isLoading(doctor.id) && reviews.isEmpty;

    // Build a simple star distribution from available reviews.
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      dist[r.rating.round()] = (dist[r.rating.round()] ?? 0) + 1;
    }
    final totalForDist = reviews.isEmpty ? 1 : reviews.length;

    return Scaffold(
      appBar: AppBar(title: Text('Reviews · ${doctor.name.split(' ').take(2).join(' ')}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          FadeIn(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.softGreenTint,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RatingStars(rating: rating, size: 16),
                      const SizedBox(height: 6),
                      Text(
                        '$count reviews',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1]
                          .map((s) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.5),
                                child: _DistRow(
                                  star: s,
                                  fraction: (dist[s] ?? 0) / totalForDist,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No reviews yet. Be the first to share your experience after a '
                'visit.',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            )
          else
            ...reviews.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FadeIn(
                      delay: Duration(milliseconds: (e.key.clamp(0, 8)) * 50),
                      child: ReviewTile(review: e.value),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _DistRow extends StatelessWidget {
  final int star;
  final double fraction;

  const _DistRow({required this.star, required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$star',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, size: 13, color: AppColors.star),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppColors.mintDark,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primaryBright),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
