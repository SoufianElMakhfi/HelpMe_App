import 'package:flutter/material.dart';

/// HelpMe Design System – Animationskonstanten
abstract class AppAnimations {
  // ── Durations ─────────────────────────────────────────
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const spring = Duration(milliseconds: 500);

  // ── Curves ────────────────────────────────────────────
  static const springCurve = Curves.elasticOut;
  static const defaultCurve = Curves.easeInOut;
  static const bounceCurve = Curves.bounceOut;
}
