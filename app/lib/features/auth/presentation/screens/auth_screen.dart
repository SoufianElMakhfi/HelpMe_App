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
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn; // Explicit Import
import 'package:flutter/foundation.dart'; // Check kIsWeb

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

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // WEB: Use Supabase OAuth direct flow (Standard & Reliable)
      if (kIsWeb) {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? 'http://localhost:3000' : null, // Callback URL we set up
          scopes: 'email profile openid',
        );
        // Note: On Web, this triggers a redirect. The app will reload.
        return; 
      }

      // MOBILE (Android/iOS): Use Google Sign-In Plugin (Native Experience)
      const webClientId = '894854190451-2vd61l8er7po9gqr6h34dudcc3ag9g17.apps.googleusercontent.com'; 
      const iosClientId = '894854190451-2vd61l8er7po9gqr6h34dudcc3ag9g17.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId, // Android needs Web Client ID
        scopes: ['email', 'profile', 'openid'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
         setState(() => _isLoading = false);
         return; // User cancelled
      }
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (mounted) {
        await _redirectUser();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _redirectUser() async {
    if (!mounted) return;
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Use maybeSingle() to handle cases where profile doesn't exist yet gracefully
      final data = await Supabase.instance.client
          .from('profiles')
          .select() 
          .eq('id', userId)
          .maybeSingle();
      
      if (!mounted) return;

      // Default role if nothing found (e.g. new user)
      String effectiveRole = widget.roleId; 
      
      if (data != null) {
          final dbRole = data['role'] as String?;
          final street = data['street'] as String?;
          
          // 1. Check Role Mismatch
          if (dbRole != null && dbRole != widget.roleId) {
            final actualRoleLabel = (dbRole == 'craftsman') ? 'Handwerker' : 'Kunde';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Info: Sie sind bereits als $actualRoleLabel registriert.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
            effectiveRole = dbRole;
          } else if (dbRole != null) {
            effectiveRole = dbRole;
          }

          // 2. Check Profile Completeness (simplified)
          bool isProfileComplete = (street != null && street.isNotEmpty);

          if (!isProfileComplete) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => ProfileSetupScreen(role: effectiveRole)),
                (route) => false,
              );
              return;
          }
      } else {
         // No profile data -> Go to Setup with intended role
         Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => ProfileSetupScreen(role: effectiveRole)),
            (route) => false,
          );
          return;
      }

      // 3. Redirect to Dashboard
      if (effectiveRole == 'customer') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CraftsmanHomeScreen()),
          (route) => false,
        );
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


                    const SizedBox(height: AppSpacing.xl),
                    
                    // Divider "Oder"
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.textSecondary)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text('ODER', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                        ),
                        const Expanded(child: Divider(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Google Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _googleSignIn,
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                        label: const Text('Weiter mit Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textInverse,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          side: const BorderSide(color: AppColors.textSecondary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),

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
