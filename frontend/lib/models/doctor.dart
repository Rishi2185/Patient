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
    required this.languages,
    required this.patientsServed,
    required this.availableToday,
    required this.availableDays,
    this.consultStart = '09:00',
    this.consultEnd = '17:00',
  });

  String get consultTimings => '$consultStart AM - $consultEnd PM';
}
