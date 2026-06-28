/// A patient review left on a doctor profile.
class Review {
  final String id;
  final String doctorId;
  final String patientName;
  final double rating; // 1.0 - 5.0
  final String comment;
  final DateTime date;
  final String? patientAvatarUrl;

  const Review({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.date,
    this.patientAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final avatar = (json['patientAvatarUrl'] ?? '') as String;
    return Review(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      doctorId: (json['doctorId'] ?? '') as String,
      patientName: (json['patientName'] ?? '') as String,
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      comment: (json['comment'] ?? '') as String,
      date: DateTime.tryParse((json['date'] ?? '') as String? ?? '') ??
          DateTime.now(),
      patientAvatarUrl: avatar.isEmpty ? null : avatar,
    );
  }
}
