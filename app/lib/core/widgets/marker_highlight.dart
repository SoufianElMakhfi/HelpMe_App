import 'package:flutter/material.dart';
import 'package:helpme/core/theme/app_colors.dart';
import 'package:helpme/core/theme/app_animations.dart';

/// Marker-Effekt Widget – simuliert einen Textmarker-Highlight
/// hinter dem Text, wie ein gelber Marker-Strich.
///
/// Verwendet im Onboarding und überall wo Headlines hervorgehoben werden.
class MarkerHighlight extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color color;
  final double heightFactor;
  final double verticalOffset;
  final bool animate;

  const MarkerHighlight({
    super.key,
    required this.text,
    this.style,
    this.color = AppColors.accentPrimary,
    this.heightFactor = 0.35,
    this.verticalOffset = 0.3,
    this.animate = true,
  });

  @override
  State<MarkerHighlight> createState() => _MarkerHighlightState();
}

class _MarkerHighlightState extends State<MarkerHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    _widthAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ??
        Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            );

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _MarkerPainter(
            progress: _widthAnimation.value,
            color: widget.color.withValues(alpha: 0.25),
            heightFactor: widget.heightFactor,
            verticalOffset: widget.verticalOffset,
          ),
          child: child,
        );
      },
      child: Text(
        widget.text,
        style: effectiveStyle,
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double heightFactor;
  final double verticalOffset;

  _MarkerPainter({
    required this.progress,
    required this.color,
    required this.heightFactor,
    required this.verticalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final markerHeight = size.height * heightFactor;
    final top = size.height * (1 - verticalOffset);

    // Leicht schräger Marker-Strich für organisches Gefühl
    final path = Path()
      ..moveTo(0, top - 2)
      ..lineTo(size.width * progress, top)
      ..lineTo(size.width * progress, top + markerHeight)
      ..lineTo(0, top + markerHeight - 1)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
