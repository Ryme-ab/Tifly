import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/features/navigation/presentation/screens/main_tab_screen.dart';
import 'package:tifli/features/profiles/presentation/screens/create_baby_screen.dart';
import 'package:tifli/features/auth/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    // BOUNCE ANIMATION
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoController.forward();

    // Check auth and navigate
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;

      if (user == null) {
        // Not authenticated → go to onboarding/login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
        return;
      }

      // User is authenticated, check if they have babies
      final response = await _supabase
          .from('children')
          .select()
          .eq('parent_id', user.id)
          .limit(1);

      final hasBabies = (response as List).isNotEmpty;

      if (!mounted) return;

      if (hasBabies) {
        // Has babies → go to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
        );
      } else {
        // No babies → go to create baby page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddBabyPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // On error, go to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEEF1), Color(0xFFFFF8FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo_notext.png", width: 230),
                const SizedBox(height: 20),
                Text(
                  "Tifli",
                  style: AppFonts.heading1.copyWith(
                    fontSize: 30,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 40),
                // Loading indicator
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
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
