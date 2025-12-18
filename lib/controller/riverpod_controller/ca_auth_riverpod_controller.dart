/// This controller handles all authentication logic for Campus Ambassador users.
/// It manages login, token validation, user data fetching, and logout.
library;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techniche26/constant/global.dart';
import 'package:techniche26/utils/ca_bottom_nav_bar.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:techniche26/controller/riverpod_controller/ca_user_provider.dart';

/// Provider for accessing CA Authentication Controller
final caAuthControllerProvider = Provider((ref) => CaAuthController(ref));

/// CA Authentication Controller
///
/// Handles all Campus Ambassador authentication flows:
/// - Sign in with email/password
/// - Token validation
/// - User data fetching
/// - Logout
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF00F7)),
                ),
                SizedBox(height: 20),
                Text(
                  "Signing in...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      const uri = GlobalVariables.baseUrl;

      final response = await http.post(
        Uri.parse("$uri/caauth/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['token'] != null) {
          // Save token to SharedPreferences for persistence
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ca_token', responseData['token']);

          // Create complete user data with token
          final userData = {
            ...responseData,
            'token': responseData['token'],
          };

          // Update Riverpod state
          _ref.read(caUserProvider.notifier).setUser(jsonEncode(userData));

          // Show "Loading account..." dialog while fetching user data
          if (context.mounted) {
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
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFF00F7)),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Loading account data...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // Fetch full profile
          await fetchUserData(context);

          // Hide the second loading dialog
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          showMessage(context, "Logged in Successfully!");
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, CaBottomNavBar.routeName, (route) => false);
          }
          return true;
        } else {
          showMessage(context, "Login failed - no token received",
              isError: true);
        }
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Login failed';
        showMessage(context, errorMessage, isError: true);
      }
      return false;
    } catch (e) {
      // Hide loading dialog in case of error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      print("CA Login error: $e");
      showMessage(context, "An error occurred during login", isError: true);
      await _clearAuthData(context);
      return false;
    }
  }

  /// Check if CA user is authenticated (has valid token)
  Future<bool> isCaUserAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("ca_token");

      if (token == null || token.isEmpty) {
        return false;
      }

      try {
        final parts = token.split('.');
        if (parts.length != 3) {
          return false;
        }

        String normalizedPayload = base64Url.normalize(parts[1]);
        Map<String, dynamic> payload =
            json.decode(utf8.decode(base64Url.decode(normalizedPayload)));

        if (payload.containsKey('exp')) {
          int expiry = payload['exp'];
          int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          if (now >= expiry) {
            return false;
          }
        }
      } catch (e) {
        print("CA Token parsing error: $e");
        return false;
      }

      return true;
    } catch (e) {
      print("CA Auth check error: $e");
      return false;
    }
  }

  /// Validate token with server and fetch user data
  Future<bool> validateTokenAndFetchUser(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("ca_token");

      if (token == null || token.isEmpty) {
        return false;
      }

      String uri = GlobalVariables.baseUrl;

      // Validate token
      final tokenRes = await http.post(
        Uri.parse("$uri/caauth/validatetokenApp"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'token': token,
        },
      );

      if (tokenRes.statusCode != 200) {
        await _clearAuthData(context);
        return false;
      }

      final bool isValid = jsonDecode(tokenRes.body);
      if (!isValid) {
        await _clearAuthData(context);
        return false;
      }

      // Show loading while fetching user data
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF00F7)),
              ),
            );
          },
        );
      }

      // If token is valid, fetch user data
      await fetchUserData(context);

      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return true;
    } catch (e) {
      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      print("CA Token validation error: $e");
      await _clearAuthData(context);
      return false;
    }
  }

  /// Fetch CA user data from server
  Future<void> fetchUserData(BuildContext context) async {
    try {
      print("Starting fetchUserData (CA Riverpod)");
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("ca_token");

      if (token == null || token.isEmpty) {
        await _clearAuthData(context);
        return;
      }

      String uri = GlobalVariables.baseUrl;

      // Validate token
      final tokenRes = await http.post(
        Uri.parse("$uri/caauth/validatetokenApp"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'token': token,
        },
      );

      if (tokenRes.statusCode != 200 || !jsonDecode(tokenRes.body)) {
        await _clearAuthData(context);
        return;
      }

      // Fetch user data
      final userRes = await http.get(
        Uri.parse("$uri/caauth/getUserApp"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'token': token,
        },
      );

      if (userRes.statusCode == 200) {
        final userData = jsonDecode(userRes.body);
        userData['token'] = token;

        // Update Riverpod state
        _ref.read(caUserProvider.notifier).setUser(jsonEncode(userData));
      } else {
        await _clearAuthData(context);
      }
    } catch (e) {
      print("Error fetching CA user data: $e");
      await _clearAuthData(context);
    }
  }

  /// Logout CA user
  Future<void> logoutUser(BuildContext context) async {
    try {
      await _clearAuthData(context);
      showMessage(context, "Logged out successfully");

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/landing-screen', (route) => false);
      }
    } catch (e) {
      print("CA Logout error: $e");
      showMessage(context, "An error occurred during logout", isError: true);
      await _clearAuthData(context);
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/landing-screen', (route) => false);
      }
    }
  }

  /// Clear all CA auth data
  Future<void> _clearAuthData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ca_token');
      await prefs.remove('ca_user');
      await prefs.remove('ca_userData');

      // Clear Riverpod state
      _ref.read(caUserProvider.notifier).clearUser();
    } catch (e) {
      print("Error clearing CA auth data: $e");
    }
  }
}
