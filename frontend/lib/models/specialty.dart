import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A medical specialty used for category browsing and filtering.
class Specialty {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Specialty({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Canonical list of specialties offered in the app.
class Specialties {
  Specialties._();

  static const Specialty cardiology = Specialty(
    id: 'cardiology',
    name: 'Cardiology',
    icon: Icons.favorite_rounded,
    color: AppColors.accentRed,
  );
  static const Specialty dermatology = Specialty(
    id: 'dermatology',
    name: 'Dermatology',
    icon: Icons.spa_rounded,
    color: AppColors.accentPink,
  );
  static const Specialty pediatrics = Specialty(
    id: 'pediatrics',
    name: 'Pediatrics',
    icon: Icons.child_care_rounded,
    color: AppColors.accentOrange,
  );
  static const Specialty gynecology = Specialty(
    id: 'gynecology',
    name: 'Gynecology',
    icon: Icons.pregnant_woman_rounded,
    color: AppColors.accentPurple,
  );
  static const Specialty ent = Specialty(
    id: 'ent',
    name: 'ENT',
    icon: Icons.hearing_rounded,
    color: AppColors.accentTeal,
  );
  static const Specialty neurology = Specialty(
    id: 'neurology',
    name: 'Neurology',
    icon: Icons.psychology_rounded,
    color: AppColors.accentBlue,
  );
  static const Specialty orthopedics = Specialty(
    id: 'orthopedics',
    name: 'Orthopedics',
    icon: Icons.accessibility_new_rounded,
    color: AppColors.primaryBright,
  );
  static const Specialty dentistry = Specialty(
    id: 'dentistry',
    name: 'Dentistry',
    icon: Icons.medical_services_rounded,
    color: AppColors.info,
  );
  static const Specialty ophthalmology = Specialty(
    id: 'ophthalmology',
    name: 'Eye Care',
    icon: Icons.visibility_rounded,
    color: AppColors.accentTeal,
  );
  static const Specialty generalPhysician = Specialty(
    id: 'general',
    name: 'General',
    icon: Icons.health_and_safety_rounded,
    color: AppColors.primary,
  );

  static const List<Specialty> all = [
    generalPhysician,
    cardiology,
    dermatology,
    pediatrics,
    gynecology,
    ent,
    neurology,
    orthopedics,
    dentistry,
    ophthalmology,
  ];

  static Specialty byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => generalPhysician);
}
