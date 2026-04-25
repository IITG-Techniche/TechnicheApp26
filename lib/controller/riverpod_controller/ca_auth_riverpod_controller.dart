library;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techniche26/utils/ca_bottom_nav_bar.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:techniche26/controller/riverpod_controller/ca_user_provider.dart';
import 'package:techniche26/services/ca_api_service.dart';

/// Provider for accessing CA Authentication Controller
final caAuthControllerProvider = Provider((ref) => CaAuthController(ref));

class CaAuthController {
  final Ref _ref;
  CaAuthController(this._ref);

  /// Sign in a CA user with email and password
  Future<bool> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // Show loading dialog
    _showLoadingDialog(context, "Signing in...");

    try {
      final response = await CaApiService.signIn(email, password);

      // Hide loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String name = responseData['name'] ?? '';
        final String t_id = responseData['t_id']?.toString() ?? '';
        final String userEmail = responseData['email'] ?? '';
        final int points = responseData['points'] ?? 0;
        final String sanitizedHash = responseData['sanitizedHash'] ?? '';

        if (name.isEmpty || t_id.isEmpty) {
          if (context.mounted) {
            showMessage(context, "Login failed — unexpected response", isError: true);
          }
          return false;
        }

        // Persist login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedInCA', true);
        await prefs.setString('ca_name', name);
        await prefs.setString('ca_t_id', t_id);
        await prefs.setString('ca_email', userEmail);
        await prefs.setInt('ca_points', points);
        await prefs.setString('ca_sanitizedHash', sanitizedHash);

        // Fetch full profile (institution, city, etc.) before navigating
        if (context.mounted) {
          await fetchUserData(context);
        }

        if (context.mounted) {
          showMessage(context, "Logged in Successfully!");
          Navigator.pushNamedAndRemoveUntil(context, CaBottomNavBar.routeName, (route) => false);
        }
        return true;
      } else if (response.statusCode == 403) {
        if (context.mounted) showMessage(context, "Please verify your email.", isError: true);
      } else {
        final body = jsonDecode(response.body);
        final errorMessage = body['message'] ?? body['error'] ?? 'Login failed';
        if (context.mounted) showMessage(context, errorMessage, isError: true);
      }
      return false;
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) showMessage(context, "An error occurred during login", isError: true);
      await _clearAuthData(context);
      return false;
    }
  }

  /// Register a new CA user
  Future<bool> registerUser({
    required BuildContext context,
    required String name,
    required String email,
    required String contact,
    required String institution,
    required String city,
    required String state,
    required String password,
  }) async {
    _showLoadingDialog(context, "Creating account...");

    try {
      final response = await CaApiService.register(
        name: name,
        email: email,
        contact: contact,
        institution: institution,
        city: city,
        state: state,
        password: password,
      );

      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Success!", style: TextStyle(fontFamily: 'Univers', fontWeight: FontWeight.bold)),
              content: const Text(
                  "Registration successful! Please check your email (and spam folder) for a verification link before logging in.",
                  style: TextStyle(fontFamily: 'General Sans')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Back to login
                  },
                  child: const Text("Got it", style: TextStyle(fontFamily: 'Univers', fontWeight: FontWeight.bold, color: Color(0xFF002B5B))),
                ),
              ],
            ),
          );
        }
        return true;
      } else if (response.statusCode == 409) {
        if (context.mounted) showMessage(context, "This email is already registered.", isError: true);
      } else {
        final body = jsonDecode(response.body);
        final error = body['message'] ?? body['error'] ?? 'Registration failed';
        if (context.mounted) showMessage(context, error, isError: true);
      }
      return false;
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) showMessage(context, "An error occurred during registration", isError: true);
      return false;
    }
  }

  /// Request a password reset link
  Future<void> requestPasswordReset(BuildContext context, String email) async {
    _showLoadingDialog(context, "Sending reset link...");

    try {
      final response = await CaApiService.forgotPassword(email);

      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        if (context.mounted) {
          showMessage(context, "Password reset link sent to your email!");
        }
      } else if (response.statusCode == 429) {
        if (context.mounted) showMessage(context, "Too many requests. Please try again later.", isError: true);
      } else {
        if (context.mounted) showMessage(context, "Failed to send reset link. User not found or server error.", isError: true);
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) showMessage(context, "An error occurred", isError: true);
    }
  }

  /// Check if CA user is authenticated and restore state
  Future<bool> isCaUserAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedInCA') ?? false;
      final String name = prefs.getString('ca_name') ?? '';
      if (!isLoggedIn || name.isEmpty) return false;

      // Restore Riverpod state
      final t_id = prefs.getString('ca_t_id') ?? '';
      final email = prefs.getString('ca_email') ?? '';
      final points = prefs.getInt('ca_points') ?? 0;
      final sanitizedHash = prefs.getString('ca_sanitizedHash') ?? '';
      final contact = prefs.getInt('ca_contact') ?? 0;
      final state = prefs.getString('ca_state') ?? '';
      final city = prefs.getString('ca_city') ?? '';
      final institution = prefs.getString('ca_institution') ?? '';

      _ref.read(caUserProvider.notifier).setUser(jsonEncode({
        'name': name,
        't_id': t_id,
        'email': email,
        'points': points,
        'token': sanitizedHash,
        'contact': contact,
        'state': state,
        'city': city,
        'institution': institution,
      }));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate session — calls fetchUserData to ensure the server still recognizes the user.
  Future<bool> validateTokenAndFetchUser(BuildContext context) async {
    return await fetchUserData(context);
  }

  /// Fetch fresh CA user data from server (Identity Sync)
  Future<bool> fetchUserData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('ca_email') ?? '';
      final String token = prefs.getString('ca_sanitizedHash') ?? '';

      if (email.isEmpty) return false;

      // Using getCaUserDetails as it returns all fields including institution/city/state
      final userData = await CaApiService.getCaUserDetails(email);

      if (userData != null) {
        final String name = userData['name'] ?? '';
        final String t_id = userData['t_id']?.toString() ?? '';
        final int points = userData['points'] ?? 0;
        final int contact = userData['contact'] ?? 0;
        final String state = userData['state'] ?? '';
        final String city = userData['city'] ?? '';
        final String institution = userData['institution'] ?? '';

        // Update SharedPreferences
        await prefs.setString('ca_name', name);
        await prefs.setString('ca_t_id', t_id);
        await prefs.setInt('ca_points', points);
        await prefs.setInt('ca_contact', contact);
        await prefs.setString('ca_state', state);
        await prefs.setString('ca_city', city);
        await prefs.setString('ca_institution', institution);

        // Update Riverpod state
        _ref.read(caUserProvider.notifier).setUser(jsonEncode({
          'name': name,
          't_id': t_id,
          'email': email,
          'points': points,
          'token': token,
          'contact': contact,
          'state': state,
          'city': city,
          'institution': institution,
        }));
        return true;
      }
      return false;
    } catch (e) {
      print("Error fetching fresh CA user data: $e");
      return false;
    }
  }

  /// Logout CA user
  Future<void> logoutUser(BuildContext context) async {
    try {
      await _clearAuthData(context);
      if (context.mounted) {
        showMessage(context, "Logged out successfully");
        Navigator.pushNamedAndRemoveUntil(context, '/landing-screen', (route) => false);
      }
    } catch (e) {
      print("Logout error: $e");
    }
  }

  /// Clear all CA auth data
  Future<void> _clearAuthData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedInCA');
      await prefs.remove('ca_name');
      await prefs.remove('ca_t_id');
      await prefs.remove('ca_email');
      await prefs.remove('ca_points');
      await prefs.remove('ca_sanitizedHash');
      await prefs.remove('ca_contact');
      await prefs.remove('ca_state');
      await prefs.remove('ca_city');
      await prefs.remove('ca_institution');
      
      _ref.read(caUserProvider.notifier).clearUser();
    } catch (e) {
      print("Clear auth data error: $e");
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B5B)),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
