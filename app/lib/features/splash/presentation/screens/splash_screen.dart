import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/screens/role_selection_screen.dart';
import '../../../dashboard/presentation/screens/customer_home_screen.dart';
import '../../../dashboard/presentation/screens/craftsman_home_screen.dart';
import '../../../profile/presentation/screens/profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Logo Animation
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    _controller.repeat(reverse: true);

    // Auth Check
    _checkSession();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    // Wait for animation to show off a bit (min 1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500)); 

    final session = Supabase.instance.client.auth.currentSession;
    
    if (!mounted) return;

    if (session == null) {
      // No user -> Role Selection
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      // User found -> Fetch Profile data
      try {
        final userId = session.user.id;
        final data = await Supabase.instance.client
            .from('profiles')
            .select() // Select ALL fields
            .eq('id', userId)
            .maybeSingle(); // Use maybeSingle to avoid crash if no profile exists yet
        
        if (data == null) {
          // Weird state (Auth exists but Profile missing) -> Logout & Restart
          await Supabase.instance.client.auth.signOut();
           if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
            );
          }
          return;
        }

        final role = data['role'] as String?;
        final street = data['street'] as String?;
        final phone = data['phone'] as String?;
        
        if (mounted) {
            // Validate Profile Completeness
            bool isComplate = (street != null && street.isNotEmpty) && (phone != null && phone.isNotEmpty);

            if (!isComplate && role != null) {
                // Incomplete Profile -> Setup Screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ProfileSetupScreen(role: role)),
                );
            } else {
                // Complete Profile -> Dashboard based on Role
                if (role == 'customer') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                  );
                } else if (role == 'craftsman') {
                   Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CraftsmanHomeScreen()),
                  );
                } else {
                  // Unknown Role -> Fallback
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  );
                }
            }
        }
      } catch (e) {
        debugPrint("Splash Error: $e");
        // Fallback on error -> Role Selection
        if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
            );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo (Pulse)
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Icon(
                Icons.bolt_rounded, 
                size: 80, 
                color: AppColors.accentPrimary
              ),
            ),
            const SizedBox(height: 24),
            // Loading Text (Optional, or simple dots)
            const Text(
              "HelpMe",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
