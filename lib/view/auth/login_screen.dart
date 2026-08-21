import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techniche26/providers/user_provider.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/view/core/landing_screen.dart';
import 'package:techniche26/utils/errorHandler.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        if (mounted) {
          final success = await ref.read(userProvider.notifier).signInWithGoogle(
            context: context,
            email: account.email,
            googleId: account.id,
            name: account.displayName,
          );

          if (success && mounted) {
            // Sync FCM Token if available
            final prefs = await SharedPreferences.getInstance();
            final fcm = prefs.getString('fcm_token');
            if (fcm != null && fcm.isNotEmpty) {
              await ref.read(userProvider.notifier).syncFcmToken(fcm);
            }
            await prefs.setBool('seenLoginGate', true);
            if (mounted) {
              Navigator.pushReplacementNamed(context, LandingScreen.routeName);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      if (mounted) {
        showMessage(context, "Google Sign-In failed due to an internet or connection issue.", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
        if (fullName.isEmpty) fullName = null;
      }

      if (mounted) {
        final success = await ref.read(userProvider.notifier).signInWithApple(
          context: context,
          appleId: credential.userIdentifier ?? '',
          email: credential.email,
          name: fullName,
          identityToken: credential.identityToken,
        );

        if (success && mounted) {
          final prefs = await SharedPreferences.getInstance();
          final fcm = prefs.getString('fcm_token');
          if (fcm != null && fcm.isNotEmpty) {
            await ref.read(userProvider.notifier).syncFcmToken(fcm);
          }
          await prefs.setBool('seenLoginGate', true);
          if (mounted) {
            Navigator.pushReplacementNamed(context, LandingScreen.routeName);
          }
        }
      }
    } catch (e) {
      debugPrint("Apple Sign-In Error: $e");
      if (mounted) {
        showMessage(context, "Apple Sign-In failed due to an internet or connection issue.", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skipLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenLoginGate', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, LandingScreen.routeName);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://techniche.org.in/privacy');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) showMessage(context, "Privacy Policy: https://techniche.org.in/privacy");
      }
    } catch (_) {
      if (mounted) showMessage(context, "Privacy Policy: https://techniche.org.in/privacy");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching App Theme with a rich dark cyberpunk overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001124), Color(0xFF002B5B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Subtle circular ambient light effects
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF175BCC).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF175BCC).withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Logo
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title Text
                    const Text(
                      'TECHNICHE',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUnivers,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'IIT Guwahati\'s Premier Techno-Management Fest',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontGeneralSans,
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Login card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: AppTheme.fontUnivers,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Join the official Techniche community to access the event registrations, workshops, merchandise, and more.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontGeneralSans,
                              fontSize: 13,
                              color: Colors.white60,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Login Buttons
                          if (_isLoading)
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          else ...[
                            ElevatedButton(
                              onPressed: _handleGoogleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF232930),
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                    height: 22,
                                    width: 22,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Sign In with Google',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontGeneralSans,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                              const SizedBox(height: 12),
                              SignInWithAppleButton(
                                onPressed: _handleAppleSignIn,
                                style: SignInWithAppleButtonStyle.black,
                                borderRadius: BorderRadius.circular(16),
                                height: 50,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Skip / Continue as Guest
                    TextButton(
                      onPressed: _skipLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue as Guest',
                            style: TextStyle(
                              fontFamily: AppTheme.fontGeneralSans,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _openPrivacyPolicy,
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontFamily: AppTheme.fontGeneralSans,
                          color: Colors.white60,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
