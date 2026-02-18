import 'package:flutter/material.dart';
import 'package:helpme/core/theme/app_colors.dart';
import 'package:helpme/core/theme/app_spacing.dart';
import 'package:helpme/core/theme/app_animations.dart';

/// Onboarding Screen – Rollenauswahl
/// Bold & Clean Design – Inspiriert von modernem App-UI
///
/// Entspricht User Story 1.2 (Rollen-Auswahl)
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedRole;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideTop;
  late Animation<Offset> _slideBottom;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideTop = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    _slideBottom = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onRoleSelected(String role) {
    setState(() => _selectedRole = role);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              role == 'customer'
                  ? '✓ Weiterleitung zum Kunden-Dashboard...'
                  : '✓ Weiterleitung zum Handwerker-Dashboard...',
              style: const TextStyle(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.accentPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // ── Header ─────────────────────────────────
                _buildHeader(),

                const SizedBox(height: AppSpacing.xxl),

                // ── Cards (Expanded) ───────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _slideTop,
                    child: _RoleCard(
                      title: 'Ich brauche\nHilfe',
                      subtitle: 'Finde Handwerker',
                      emoji: '🏠',
                      imagePath: 'assets/images/customer_character.png',
                      accentColor: AppColors.accentPrimary,
                      tag: 'Kunde',
                      isSelected: _selectedRole == 'customer',
                      isOtherSelected: _selectedRole == 'craftsman',
                      onTap: () => _onRoleSelected('customer'),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Expanded(
                  child: SlideTransition(
                    position: _slideBottom,
                    child: _RoleCard(
                      emoji: '⚡',
                      title: 'Ich biete\nHandwerk',
                      subtitle: 'Erhalte Aufträge',
                      imagePath: 'assets/images/craftsman_character.png',
                      accentColor: AppColors.accentSecondary,
                      tag: 'Handwerker',
                      isSelected: _selectedRole == 'craftsman',
                      isOtherSelected: _selectedRole == 'customer',
                      onTap: () => _onRoleSelected('craftsman'),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Footer ─────────────────────────────────
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Bereits registriert? ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Anmelden',
                          style: TextStyle(
                            color: AppColors.accentPrimary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accentPrimary.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo bar
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('H',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textInverse,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'HelpMe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Outfit',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Big title
        const Text(
          'Was beschreibt\ndich am besten?',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            fontFamily: 'Outfit',
            color: AppColors.textPrimary,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Role Card – Bold Flat Design
// ─────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final String imagePath; // 3D Character image
  final Color accentColor;
  final String tag;
  final bool isSelected;
  final bool isOtherSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.imagePath,
    required this.accentColor,
    required this.tag,
    required this.isSelected,
    required this.isOtherSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_pressController.value * 0.025),
            child: child,
          );
        },
        child: AnimatedOpacity(
          duration: AppAnimations.normal,
          opacity: widget.isOtherSelected ? 0.4 : 1.0,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.accentColor
                  : AppColors.bgElevated,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag + Emoji row
                      Row(
                        children: [
                          // Tag pill
                          AnimatedContainer(
                            duration: AppAnimations.normal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? Colors.black.withValues(alpha: 0.15)
                                  : widget.accentColor.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              widget.tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.isSelected
                                    ? AppColors.textInverse
                                    : widget.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Title
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                          color: widget.isSelected
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                          height: 1.15,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Subtitle
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isSelected
                              ? AppColors.textInverse.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // CTA Row
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: AppAnimations.normal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? AppColors.textInverse
                                  : widget.accentColor,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.isSelected
                                      ? 'Ausgewählt'
                                      : 'Auswählen',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: widget.isSelected
                                        ? widget.accentColor
                                        : AppColors.textInverse,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  widget.isSelected
                                      ? Icons.check_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: widget.isSelected
                                      ? widget.accentColor
                                      : AppColors.textInverse,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Character Image (right side)
                Positioned(
                  right: -80,
                  bottom: -20,
                  child: AnimatedScale(
                    scale: widget.isSelected ? 1.05 : 1.0,
                    duration: AppAnimations.normal,
                    child: Image.asset(
                      widget.imagePath,
                      height: 320,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
