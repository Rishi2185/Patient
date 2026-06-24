import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Aarvy mark: a rounded tile with a heart-plus medical glyph.
class AppLogo extends StatelessWidget {
  final double size;
  final bool light; // light = white tile on dark bg

  const AppLogo({super.key, this.size = 72, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? Colors.white : null,
        gradient: light ? null : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: light ? 0.25 : 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.health_and_safety_rounded,
        size: size * 0.56,
        color: light ? AppColors.primary : Colors.white,
      ),
    );
  }
}
