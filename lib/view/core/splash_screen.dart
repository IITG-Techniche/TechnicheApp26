library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/providers/marathon_provider.dart';
import 'package:techniche26/view/core/landing_screen.dart';
import 'package:techniche26/view/core/onboarding_screen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:techniche26/constant/sharedPerfence.dart';
import 'package:techniche26/view/auth/login_screen.dart';

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
    // Initialize remote config after app start
    _setupRemoteConfig();
    _showSplashAndNavigate();
  }

  Future<void> _setupRemoteConfig() async {
    if (!kIsWeb) {
      try {
        final remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ));
        await remoteConfig.setDefaults(const {
          "marathon_registrations_open": true,
        });
        await remoteConfig.fetchAndActivate();
      } catch (e) {
        debugPrint("Error initializing Remote Config: $e");
      }
    }
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

      // Restore Marathon Enrollment state
      if (mounted) {
        await loadMarathonEnrollment(ref);
      }
    } catch (e) {
      // Silently ignore - user will just not be logged in
      print("Error restoring auth or marathon state: $e");
    }

    // Navigate to Landing Screen or Login Screen depending on login state/history
    if (mounted) {
      final userToken = prefs.getString(SharedPreferenceConstants.userToken) ?? '';
      final seenLoginGate = prefs.getBool('seenLoginGate') ?? false;

      if (userToken.isEmpty && !seenLoginGate) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, LandingScreen.routeName);
      }
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
