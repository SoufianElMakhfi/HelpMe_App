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
    return Scaffold(
      // We use transparent background because the Hero container will provide the color
      backgroundColor: widget.accentColor,
      body: Stack(
        children: [
          // 1. Hero Background Layer
          // This expands from the card in the previous screen
          Positioned.fill(
            child: Hero(
              tag: 'hero_bg_${widget.roleId}',
              child: Container(
                color: widget.accentColor,
              ),
            ),
          ),

          // 2. Hero Image
          // Flies from the card to top-right
          // 2. Character Image (Centered, No Hero Animation)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Image.asset(
              widget.imagePath,
              height: 280, // Bigger image
              fit: BoxFit.contain,
            ),
          ),

          // 3. Content (Fade in)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md), // Top padding
                  
                  // Back Button (Styled)
                  Container(
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
                  ),

                  // Spacer for centered image
                  // Image is at top, taking ~380 height + 60 top padding = 440.
                  // But Title is overlaying/underneath?
                  // We want Title below image? Or Title above image?
                  // User said "Welcome text tiefer und größer".
                  // Let's put Title below image.
                  const SizedBox(height: 240),

                  // Title (Top Left)
                  Text(
                    'Willkommen,\n${widget.roleLabel}!',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 48, // Bigger font size
                      fontWeight: FontWeight.w900,
                      color: AppColors.textInverse,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg), // Normal spacing to Google button 

                  // Google Button (Social First)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Google Login
                      },
                      icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                      label: const Text('Mit Google fortfahren'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textInverse,
                        side: BorderSide(color: AppColors.textInverse.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Divider (ODER)
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.textInverse.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'ODER',
                          style: TextStyle(
                            color: AppColors.textInverse.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.textInverse.withValues(alpha: 0.3))),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Toggle Login/Register Tabs
                  Row(
                    children: [
                      _buildAuthTab('Anmelden', _isLogin),
                      const SizedBox(width: AppSpacing.lg),
                      _buildAuthTab('Registrieren', !_isLogin),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Form Fields
                  _buildTextField('E-Mail Adresse', Icons.email_outlined, controller: _emailController),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField('Passwort', Icons.lock_outline, isPassword: true, controller: _passwordController),

                  const SizedBox(height: AppSpacing.lg), // Space instead of Spacer

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitAuth, // Bind logic
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textInverse,
                        foregroundColor: widget.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: _isLoading 
                        ? SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(
                              color: widget.accentColor, 
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Anmelden' : 'Registrieren',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthTab(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isLogin = text == 'Anmelden'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.textInverse : AppColors.textInverse.withOpacity(0.5),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 24,
            color: isActive ? AppColors.textInverse : Colors.transparent,
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
