import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/specialty.dart';
import '../../state/auth_provider.dart';
import '../../state/doctor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/load_error.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_header.dart';
import '../../widgets/specialty_chip.dart';
import '../doctors/doctor_detail_screen.dart';
import '../doctors/doctor_list_screen.dart';
import '../main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openList(BuildContext context,
      {String? specialtyId, bool focusSearch = false}) {
    final provider = context.read<DoctorProvider>();
    provider.clearFilters();
    provider.setQuery('');
    if (specialtyId != null) provider.setSpecialty(specialtyId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoctorListScreen(autofocusSearch: focusSearch),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final doctorProvider = context.watch<DoctorProvider>();
    final topDoctors = doctorProvider.topRated;
    final availableToday = doctorProvider.availableToday;
    final doctorsLoading = doctorProvider.loading && topDoctors.isEmpty;
    final doctorsError = doctorProvider.error;
    final showError = !doctorProvider.loading &&
        doctorsError != null &&
        topDoctors.isEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(name: user?.username ?? 'there'),
            const SizedBox(height: 4),
            // Specialties
            FadeIn(
              delay: const Duration(milliseconds: 120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: SectionHeader(
                  title: 'Specialities',
                  actionLabel: 'See all',
                  onAction: () => _openList(context),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FadeIn(
              delay: const Duration(milliseconds: 160),
              child: SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: Specialties.all.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final s = Specialties.all[i];
                    return SpecialtyTile(
                      specialty: s,
                      onTap: () => _openList(context, specialtyId: s.id),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Promo banner
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _HealthBanner(),
              ),
            ),
            const SizedBox(height: 24),
            if (doctorsLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 56),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (showError)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: LoadError(
                  message: doctorsError,
                  onRetry: () =>
                      context.read<DoctorProvider>().load(force: true),
                ),
              )
            else ...[
              // Top doctors rail
              FadeIn(
                delay: const Duration(milliseconds: 240),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Top doctors',
                    actionLabel: 'See all',
                    onAction: () => _openList(context),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 178,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: topDoctors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    final d = topDoctors[i];
                    return FadeIn(
                      delay: Duration(milliseconds: 260 + i * 50),
                      child: DoctorMiniCard(
                        doctor: d,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctor: d),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Available today
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Available today',
                    actionLabel: 'See all',
                    onAction: () {
                      final p = context.read<DoctorProvider>();
                      p.clearFilters();
                      p.setQuery('');
                      p.setAvailableTodayOnly(true);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DoctorListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (availableToday.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text(
                    'No doctors are marked available today right now.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                )
              else
                ...availableToday.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: FadeIn(
                          delay: Duration(milliseconds: 80 + e.key * 60),
                          child: DoctorCard(
                            doctor: e.value,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DoctorDetailScreen(doctor: e.value),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;

  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleIcon(
                icon: Icons.notifications_none_rounded,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => MainShell.of(context)?.goTo(3),
                child: Avatar(
                  name: name,
                  size: 46,
                  background: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SearchField(
            readOnly: true,
            onTap: () {
              final p = context.read<DoctorProvider>();
              p.clearFilters();
              p.setQuery('');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorListScreen(autofocusSearch: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _HealthBanner extends StatelessWidget {
  const _HealthBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'HEALTH TIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Free general check-up',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Book a consult and get your\nvitals assessed for free.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volunteer_activism_rounded,
                color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}
