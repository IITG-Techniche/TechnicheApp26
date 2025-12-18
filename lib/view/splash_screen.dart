library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/view/landing_screen.dart';
import 'package:techniche26/view/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _showSplashAndNavigate();
  }

  Future<void> _showSplashAndNavigate() async {
    // 4-second splash
    await Future.delayed(const Duration(seconds: 4));
    final prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      // First-time user → onboarding
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
      return;
    }

    // Check if CA user is authenticated
    try {
      String? token = prefs.getString("ca_token");
      if (token != null && token.isNotEmpty) {
        // Restore CA user state silently
        if (mounted) {
          await ref.read(caAuthControllerProvider).fetchUserData(context);
        }
      }
    } catch (e) {
      // Silently ignore - user will just not be logged in
      print("Error restoring CA auth state: $e");
    }

    // Always navigate to Landing Screen
    // User can access CA Portal from there if they're authenticated
    if (mounted) {
      Navigator.pushReplacementNamed(context, LandingScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/splash.json',
          width: 175,
          height: 175,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
