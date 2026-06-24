import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography for the app. Uses Poppins for display/headings and
/// Inter for body text — modern, highly legible, accessible.
///
/// google_fonts falls back gracefully to the platform default font if the
/// network font cannot be fetched, so the app still works fully offline.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(TextTheme base) {
    final display = GoogleFonts.poppinsTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);

    return base.copyWith(
      // Display & headlines -> Poppins
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: display.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: display.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // Body & labels -> Inter
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: AppColors.textTertiary,
        height: 1.4,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      ),
    );
  }
}
