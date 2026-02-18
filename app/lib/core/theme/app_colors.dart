import 'package:flutter/material.dart';

/// HelpMe Design System – Farbkonstanten
/// Bold & Clean: Inspiriert von modernem App-Design mit kräftigen Akzentfarben
abstract class AppColors {
  // ── Backgrounds (Dark Mode) ──────────────────────────
  static const bgPrimary = Color(0xFF0E121A);      // Fast-Schwarz
  static const bgSecondary = Color(0xFF161B25);     // Etwas heller
  static const bgElevated = Color(0xFF1E2430);      // Card-Hintergrund
  static const bgSurface = Color(0xFF262D3A);       // Surface

  // ── Backgrounds (Light Mode) ─────────────────────────
  static const bgPrimaryLight = Color(0xFFF0F0F0);
  static const bgSecondaryLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF5F5F7);
  static const bgSurfaceLight = Color(0xFFE8E8EC);

  // ── Accent Colors ────────────────────────────────────
  static const accentPrimary = Color(0xFFF7C846);   // Warmes Gold
  static const accentSecondary = Color(0xFF8AE98D);  // Mint-Grün
  static const accentDanger = Color(0xFFFC574E);     // Coral/Rot
  static const accentLight = Color(0xFFF0F0F0);      // Helles Grau

  // ── Semantic Colors ──────────────────────────────────
  static const success = Color(0xFF8AE98D);
  static const danger = Color(0xFFFC574E);
  static const warning = Color(0xFFF7C846);
  static const info = Color(0xFF5B9CF6);

  // ── Text Colors (Dark Mode) ──────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A919E);
  static const textMuted = Color(0xFF4A5568);
  static const textInverse = Color(0xFF0E121A);

  // ── Text Colors (Light Mode) ─────────────────────────
  static const textPrimaryLight = Color(0xFF0E121A);
  static const textSecondaryLight = Color(0xFF4A5568);
  static const textMutedLight = Color(0xFF8A919E);
}
