import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/doctor.dart';
import '../models/review.dart';

/// Holds reviews (seeded + patient-added) and computes aggregate ratings.
class ReviewProvider extends ChangeNotifier {
  final List<Review> _added = [];
  int _seq = 1000;

  List<Review> reviewsForDoctor(String doctorId) {
    final list = [
      ..._added.where((r) => r.doctorId == doctorId),
      ...MockData.reviewsForDoctor(doctorId),
    ];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addReview({
    required String doctorId,
    required String patientName,
    required double rating,
    required String comment,
    required DateTime date,
  }) {
    _added.add(
      Review(
        id: 'ur${_seq++}',
        doctorId: doctorId,
        patientName: patientName,
        rating: rating,
        comment: comment,
        date: date,
      ),
    );
    notifyListeners();
  }

  /// Aggregate rating that blends the doctor's seed rating with any new
  /// patient reviews added during the session.
  double aggregateRating(Doctor doctor) {
    final added = _added.where((r) => r.doctorId == doctor.id).toList();
    if (added.isEmpty) return doctor.rating;
    final baseTotal = doctor.rating * doctor.reviewCount;
    final addedTotal = added.fold<double>(0, (sum, r) => sum + r.rating);
    final count = doctor.reviewCount + added.length;
    return (baseTotal + addedTotal) / count;
  }

  int aggregateCount(Doctor doctor) {
    final added = _added.where((r) => r.doctorId == doctor.id).length;
    return doctor.reviewCount + added;
  }
}
