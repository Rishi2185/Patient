import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hospital.dart';
import '../../state/doctor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/network_image_box.dart';
import '../../widgets/section_header.dart';
import '../doctors/doctor_detail_screen.dart';

class HospitalDetailScreen extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailScreen({super.key, required this.hospital});

  static const _facilityIcons = {
    'emergency': Icons.emergency_rounded,
    'pharmacy': Icons.local_pharmacy_rounded,
    'icu': Icons.monitor_heart_rounded,
    'ambulance': Icons.airport_shuttle_rounded,
    'lab': Icons.biotech_rounded,
    'parking': Icons.local_parking_rounded,
    'cafe': Icons.local_cafe_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final doctors = context.watch<DoctorProvider>().byHospital(hospital.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageBox(url: hospital.imageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.star, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${hospital.rating}  ·  ${hospital.openHours}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                FadeIn(child: _ActionRow(hospital: hospital)),
                const SizedBox(height: 22),
                const FadeIn(child: _Heading('About')),
                const SizedBox(height: 8),
                FadeIn(
                  child: Text(
                    hospital.about,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const FadeIn(child: _Heading('Photos')),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hospital.galleryUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => NetworkImageBox(
                      url: hospital.galleryUrls[i],
                      width: 150,
                      height: 110,
                      radius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const FadeIn(child: _Heading('Departments')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: hospital.departments
                      .map((d) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                const FadeIn(child: _Heading('Facilities')),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: hospital.facilities
                      .map((f) => _FacilityTile(
                            icon: _facilityIcons[f.icon] ??
                                Icons.check_circle_rounded,
                            label: f.label,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                const FadeIn(child: _Heading('Location')),
                const SizedBox(height: 12),
                _MapMock(hospital: hospital),
                const SizedBox(height: 24),
                SectionHeader(title: 'Doctors at ${hospital.city} branch'),
                const SizedBox(height: 14),
                ...doctors.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DoctorCard(
                      doctor: d,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailScreen(doctor: d),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final Hospital hospital;

  const _ActionRow({required this.hospital});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.call_rounded,
            label: 'Call',
            onTap: () => _toast(context, 'Calling ${hospital.phone}…'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.directions_rounded,
            label: 'Directions',
            onTap: () => _toast(context, 'Opening directions in Maps…'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () => _toast(context, 'Share link copied'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.softGreenTint,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FacilityTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMock extends StatelessWidget {
  final Hospital hospital;

  const _MapMock({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Stylised map background.
          CustomPaint(painter: _MapPainter()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.elevatedShadow,
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 26),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${hospital.address}, ${hospital.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.directions_rounded,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight painter that fakes a map (roads + blocks) without any SDK.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE9F1EC);
    canvas.drawRect(Offset.zero & size, bg);

    final block = Paint()..color = const Color(0xFFDDE9E1);
    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 50) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 8, y + 8, 40, 32),
            const Radius.circular(4),
          ),
          block,
        );
      }
    }

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 8;
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
