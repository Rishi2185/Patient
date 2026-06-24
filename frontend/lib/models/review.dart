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
}
