import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_animations.dart';
import 'package:helpme/features/dashboard/presentation/screens/customer_home_screen.dart';
import 'package:helpme/features/dashboard/presentation/screens/craftsman_home_screen.dart';
import 'package:helpme/features/profile/presentation/screens/profile_setup_screen.dart'; // Import ProfileSetup

class AuthScreen extends StatefulWidget {
  final String roleId;
  final Color accentColor;
  final String imagePath;
  final String roleLabel;

  const AuthScreen({
    super.key,
    required this.roleId,
    required this.accentColor,
    required this.imagePath,
    required this.roleLabel,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _redirectUser() async {
    if (!mounted) return;
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select() // Select ALL fields to check completeness
          .eq('id', userId)
          .single();
      
      final role = data['role'] as String?;
      final street = data['street'] as String?;
      final phone = data['phone'] as String?;
      
      if (mounted) {
        // Build Profile Setup Route
        if (role == null) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler: Keine Rolle im Profil gefunden.')),
          );
          return;
        }

        // Check completeness
        bool isProfileComplete = (street != null && street.isNotEmpty) && (phone != null && phone.isNotEmpty);

        if (!isProfileComplete) {
            // Redirect to Setup
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => ProfileSetupScreen(role: role)),
              (route) => false,
            );
        } else {
            // Redirect to Dashboard
            if (role == 'customer') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                (route) => false,
              );
            } else if (role == 'craftsman') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CraftsmanHomeScreen()),
                (route) => false,
              );
            }
        }
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden des Profils.')),
        );
      }
    }
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte fülle alle Felder aus.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      if (_isLogin) {
        // ── Login ──────────────────────────────────────────────
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erfolgreich eingeloggt!')),
          );
          await _redirectUser(); 
        }
      } else {
        // ── Register ───────────────────────────────────────────
        await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'role': widget.roleId}, 
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrierung erfolgreich!')),
          );
          await _redirectUser();
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein unerwarteter Fehler ist aufgetreten: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.35; // Image takes 35% of screen height
    // Clamp image height to reasonable limits
    final effectiveImageHeight = imageHeight.clamp(200.0, 500.0);

    return Scaffold(
      // We use transparent background because the Hero container will provide the color
      backgroundColor: widget.accentColor,
      body: Stack(
        children: [
          // 1. Hero Background Layer
          Positioned.fill(
            child: Hero(
              tag: 'hero_bg_${widget.roleId}',
              child: Container(
                decoration: BoxDecoration(
                  color: widget.accentColor, 
                ),
              ),
            ),
          ),

          // 2. Character Image (Centered, Responsive)
          Positioned(
            top: 60, // Fixed top (SafeArea could be better, but this is fine for now)
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500), // Max width for desktop
                child: Image.asset(
                  widget.imagePath,
                  height: effectiveImageHeight, 
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 3. Content Layer (Scrollable)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight, // Ensure full height scroll
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Back Button (Top Left)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: _buildBackButton(context),
                      ),
                    ),

                    // B. Spacer based on Image Height
                    // We want text to start BELOW the image.
                    SizedBox(height: effectiveImageHeight - 20), // -20 overlap slightly or tune

                    // Title (Top Left)
                    Text(
                      'Willkommen,\n${widget.roleLabel}!',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: (screenHeight < 700) ? 32 : 40, // Smaller font on small screens
                        fontWeight: FontWeight.w900,
                        color: AppColors.textInverse,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg), // Space to Google Button

                    // Google Sign-In Button (Black)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Google Sign-In Logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Login kommt bald! 🚧')),
                          );
                        },
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                        label: const Text('Mit Google fortfahren'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textInverse, // Black
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50), 
                            side: const BorderSide(color: Colors.white12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Divider "ODER"
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.textInverse.withValues(alpha: 0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'ODER',
                            style: TextStyle(
                              color: AppColors.textInverse.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.textInverse.withValues(alpha: 0.2))),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    
                    // Tab Switcher
                    _buildAuthTab(),

                    const SizedBox(height: AppSpacing.xl),

                    // Input Form
                    if (_isLogin) ...[
                      _buildTextField('E-Mail Adresse', Icons.email_outlined, controller: _emailController),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField('Passwort', Icons.lock_outline, isPassword: true, controller: _passwordController),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textInverse,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Anmelden'),
                        ),
                      ),
                    ] else ...[
                      _buildTextField('E-Mail Adresse', Icons.email_outlined, controller: _emailController),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField('Passwort', Icons.lock_outline, isPassword: true, controller: _passwordController),
                      const SizedBox(height: AppSpacing.md),
                       // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textInverse,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Kostenlos Registrieren'),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.textInverse,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: widget.accentColor, size: 20),
        onPressed: () => Navigator.pop(context),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildAuthTab() {
    return Row(
      children: [
        _buildTabItem('Anmelden', _isLogin, () => setState(() => _isLogin = true)),
        const SizedBox(width: AppSpacing.lg),
        _buildTabItem('Registrieren', !_isLogin, () => setState(() => _isLogin = false)),
      ],
    );
  }

  Widget _buildTabItem(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.textInverse : AppColors.textInverse.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              height: 3,
              width: 24,
              color: AppColors.textInverse,
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Pure Black background
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: TextField(
        controller: controller, // Bind controller
        obscureText: isPassword,
        style: TextStyle(
          color: widget.accentColor, 
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 1.25, // Fix line height to prevent cutting off
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: widget.accentColor.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: widget.accentColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // More padding
          isDense: false,
        ),
      ),
    );
  }
}
