/// Status of a booked appointment.
enum AppointmentStatus { upcoming, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Payment method used to confirm a booking.
enum PaymentMethod { card, upi, wallet }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Credit / Debit Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }
}

/// A booked appointment with a doctor.
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specialtyName;
  final String hospitalName;
  final DateTime dateTime;
  final String slotLabel; // e.g. "10:30 AM"
  final int fee;
  final PaymentMethod paymentMethod;
  AppointmentStatus status;
  bool reviewed;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specialtyName,
    required this.hospitalName,
    required this.dateTime,
    required this.slotLabel,
    required this.fee,
    required this.paymentMethod,
    this.status = AppointmentStatus.upcoming,
    this.reviewed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorPhotoUrl': doctorPhotoUrl,
        'specialtyName': specialtyName,
        'hospitalName': hospitalName,
        'dateTime': dateTime.toIso8601String(),
        'slotLabel': slotLabel,
        'fee': fee,
        'paymentMethod': paymentMethod.index,
        'status': status.index,
        'reviewed': reviewed,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        doctorId: json['doctorId'] as String,
        doctorName: json['doctorName'] as String,
        doctorPhotoUrl: json['doctorPhotoUrl'] as String,
        specialtyName: json['specialtyName'] as String,
        hospitalName: json['hospitalName'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        slotLabel: json['slotLabel'] as String,
        fee: json['fee'] as int,
        paymentMethod: PaymentMethod.values[json['paymentMethod'] as int],
        status: AppointmentStatus.values[json['status'] as int],
        reviewed: json['reviewed'] as bool? ?? false,
      );
}
