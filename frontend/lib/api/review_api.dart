import '../models/review.dart';
import 'api_client.dart';

/// A doctor's reviews plus the headline aggregate `{ rating, count }`.
class ReviewPage {
  final List<Review> reviews;
  final double aggregateRating;
  final int aggregateCount;

  const ReviewPage({
    required this.reviews,
    required this.aggregateRating,
    required this.aggregateCount,
  });
}

/// Doctor reviews: list for a doctor, and submit a new one (auth required).
class ReviewApi {
  final ApiClient _client;
  ReviewApi(this._client);

  /// GET /reviews?doctorId= -> `{ data, total, aggregate: { rating, count } }`.
  Future<ReviewPage> forDoctor(String doctorId,
      {int page = 1, int limit = 50}) async {
    final data = await _client.get('/reviews', query: {
      'doctorId': doctorId,
      'page': page,
      'limit': limit,
    }) as Map<String, dynamic>;
    return _page(data);
  }

  /// POST /reviews { doctorId, rating, comment, appointmentId? }
  /// -> `{ review, aggregate: { rating, count } }`.
  Future<ReviewPage> create({
    required String doctorId,
    required int rating,
    required String comment,
    String? appointmentId,
  }) async {
    final data = await _client.post('/reviews', body: {
      'doctorId': doctorId,
      'rating': rating,
      'comment': comment,
      'appointmentId': ?appointmentId,
    }) as Map<String, dynamic>;
    final agg = (data['aggregate'] ?? const {}) as Map<String, dynamic>;
    return ReviewPage(
      reviews: [
        Review.fromJson((data['review'] ?? const {}) as Map<String, dynamic>)
      ],
      aggregateRating: ((agg['rating'] ?? 0) as num).toDouble(),
      aggregateCount: (agg['count'] ?? 0) as int,
    );
  }

  ReviewPage _page(Map<String, dynamic> data) {
    final agg = (data['aggregate'] ?? const {}) as Map<String, dynamic>;
    return ReviewPage(
      reviews: (data['data'] as List? ?? const [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      aggregateRating: ((agg['rating'] ?? 0) as num).toDouble(),
      aggregateCount: (agg['count'] ?? (data['total'] ?? 0)) as int,
    );
  }
}
