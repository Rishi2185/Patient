import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../models/doctor.dart';
import '../models/review.dart';
import 'services.dart';

/// Loads a doctor's reviews from the backend and caches them per doctor, along
/// with the server's headline aggregate `{ rating, count }`. Also submits new
/// reviews (auth required).
class ReviewProvider extends ChangeNotifier {
  final Services _services;
  ReviewProvider(this._services);

  final Map<String, List<Review>> _byDoctor = {};
  final Map<String, double> _aggRating = {};
  final Map<String, int> _aggCount = {};
  final Set<String> _loading = {};

  bool isLoading(String doctorId) => _loading.contains(doctorId);

  /// Fetch reviews + aggregate for a doctor (cached after the first success).
  Future<void> loadForDoctor(String doctorId, {bool force = false}) async {
    if (_loading.contains(doctorId)) return;
    if (_byDoctor.containsKey(doctorId) && !force) return;
    _loading.add(doctorId);
    notifyListeners();
    try {
      final page = await _services.reviews.forDoctor(doctorId);
      _byDoctor[doctorId] = page.reviews;
      _aggRating[doctorId] = page.aggregateRating;
      _aggCount[doctorId] = page.aggregateCount;
    } on ApiException {
      _byDoctor.putIfAbsent(doctorId, () => const []);
    } finally {
      _loading.remove(doctorId);
      notifyListeners();
    }
  }

  /// Cached reviews for a doctor (newest first), or empty if not loaded yet.
  List<Review> reviewsForDoctor(String doctorId) {
    final list = [...(_byDoctor[doctorId] ?? const <Review>[])];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Headline rating: the server aggregate when loaded, else the doctor's own.
  double aggregateRating(Doctor doctor) =>
      _aggRating[doctor.id] ?? doctor.rating;

  /// Headline review count: the server aggregate when loaded, else the doctor's.
  int aggregateCount(Doctor doctor) =>
      _aggCount[doctor.id] ?? doctor.reviewCount;

  /// Submit a review for a visited appointment. Returns an error message, or
  /// null on success. Updates the cache + aggregate optimistically.
  Future<String?> submitReview({
    required String doctorId,
    required int rating,
    required String comment,
    String? appointmentId,
  }) async {
    try {
      final result = await _services.reviews.create(
        doctorId: doctorId,
        rating: rating,
        comment: comment,
        appointmentId: appointmentId,
      );
      final existing = _byDoctor[doctorId] ?? const <Review>[];
      _byDoctor[doctorId] = [...result.reviews, ...existing];
      _aggRating[doctorId] = result.aggregateRating;
      _aggCount[doctorId] = result.aggregateCount;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
