import 'specialty.dart';

/// A doctor that can be discovered and booked.
class Doctor {
  final String id;
  final String name;
  final Specialty specialty;
  final String qualifications; // e.g. "MBBS, MD (Cardiology)"
  final int experienceYears;
  final double rating; // aggregate, 0-5
  final int reviewCount;
  final int consultationFee; // in INR
  final String about;
  final String photoUrl;
  final String hospitalId;
  final String hospitalName; // denormalized from the backend
  final List<String> languages;
  final int patientsServed;
  final bool availableToday;
  final List<String> availableDays; // e.g. ["Mon", "Tue", ...]
  final String consultStart; // "09:00"
  final String consultEnd; // "17:00"

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualifications,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.about,
    required this.photoUrl,
    required this.hospitalId,
    this.hospitalName = '',
    required this.languages,
    required this.patientsServed,
    required this.availableToday,
    required this.availableDays,
    this.consultStart = '09:00',
    this.consultEnd = '17:00',
  });

  String get consultTimings => '$consultStart AM - $consultEnd PM';

  /// Maps the backend doctor JSON. The backend sends `specialtyId`/`specialtyName`
  /// (strings); we resolve the rich [Specialty] (icon + colour) from the local
  /// registry by id, falling back to "General" for unknown ids.
  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        specialty: Specialties.byId((json['specialtyId'] ?? 'general') as String),
        qualifications: (json['qualifications'] ?? '') as String,
        experienceYears: (json['experienceYears'] ?? 0) as int,
        rating: ((json['rating'] ?? 0) as num).toDouble(),
        reviewCount: (json['reviewCount'] ?? 0) as int,
        consultationFee: (json['consultationFee'] ?? 0) as int,
        about: (json['about'] ?? '') as String,
        photoUrl: (json['photoUrl'] ?? '') as String,
        hospitalId: (json['hospitalId'] ?? '') as String,
        hospitalName: (json['hospitalName'] ?? '') as String,
        languages:
            (json['languages'] as List?)?.map((e) => e as String).toList() ??
                const [],
        patientsServed: (json['patientsServed'] ?? 0) as int,
        availableToday: (json['availableToday'] ?? false) as bool,
        availableDays:
            (json['availableDays'] as List?)?.map((e) => e as String).toList() ??
                const [],
        consultStart: (json['consultStart'] ?? '09:00') as String,
        consultEnd: (json['consultEnd'] ?? '17:00') as String,
      );
}
