import 'package:flutter/material.dart';
import 'app_colors.dart';

/// HelpMe Design System – Typografie
/// Display: Outfit | Body: Inter | Preise: JetBrains Mono (ab Phase 2 via google_fonts)
abstract class AppTypography {
  static const _fontFamily = 'Inter';
  static const _displayFont = 'Outfit';

  // ── Custom Styles ────────────────────────────────────
  static const priceStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'monospace', // wird später JetBrains Mono
    color: AppColors.textPrimary,
  );

  // ── TextTheme für ThemeData ──────────────────────────
  static TextTheme get darkTextTheme => const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          fontFamily: _displayFont,
          color: AppColors.textPrimary,
          letterSpacing: -1.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          fontFamily: _displayFont,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: _displayFont,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: _fontFamily,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: _fontFamily,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );
}
