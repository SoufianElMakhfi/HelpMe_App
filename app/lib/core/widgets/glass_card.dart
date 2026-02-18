import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:helpme/core/theme/app_spacing.dart';

/// Glassmorphism-Container Widget
/// Kann für spätere Screens verwendet werden (z.B. Dashboard-Cards).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double borderRadius;
  final Color? borderColor;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 12,
    this.borderRadius = AppRadius.lg,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.1),
            ),
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
          child: child,
        ),
      ),
    );
  }
}
