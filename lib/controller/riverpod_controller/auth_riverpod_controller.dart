import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techniche26/constant/global.dart';
import 'package:techniche26/utils/ca_bottom_nav_bar.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:techniche26/controller/riverpod_controller/user_riverpod_provider.dart';

final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF00F7)),
                ),
                const SizedBox(height: 20),
                const Text(
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
          // Save token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);

          // Create complete user data with token
          final userData = {
            ...responseData,
            'token': responseData['token'],
          };

          // Update user provider (Riverpod)
          _ref.read(userProvider.notifier).setUser(jsonEncode(userData));

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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFF00F7)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
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
      print("Login error: $e");
      showMessage(context, "An error occurred during login", isError: true);
      await _clearAuthData(context);
      return false;
    }
  }

  Future<bool> isUserAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

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
        print("Token parsing error: $e");
        return false;
      }

      return true;
    } catch (e) {
      print("Auth check error: $e");
      return false;
    }
  }

  Future<bool> validateTokenAndFetchUser(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

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
      print("Token validation error: $e");
      await _clearAuthData(context);
      return false;
    }
  }

  Future<void> fetchUserData(BuildContext context) async {
    try {
      print("Starting fetchUserData (Riverpod)");
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        await _clearAuthData(context);
        return;
      }

      String uri = GlobalVariables.baseUrl;

      // Validate token (simplified for brevity, assume valid if calling this directly or validation happened before)
      // Ideally should re-validate or trust caller. Let's do a quick validation.
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
        _ref.read(userProvider.notifier).setUser(jsonEncode(userData));
      } else {
        await _clearAuthData(context);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      await _clearAuthData(context);
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      await _clearAuthData(context);
      showMessage(context, "Logged out successfully");

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/landing-screen', (route) => false);
      }
    } catch (e) {
      print("Logout error: $e");
      showMessage(context, "An error occurred during logout", isError: true);
      await _clearAuthData(context);
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/landing-screen', (route) => false);
      }
    }
  }

  Future<void> _clearAuthData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      await prefs.remove('userData');

      // Clear Riverpod state
      _ref.read(userProvider.notifier).clearUser();
    } catch (e) {
      print("Error clearing auth data: $e");
    }
  }
}
