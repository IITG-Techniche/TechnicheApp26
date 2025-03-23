import 'dart:convert';
import 'package:amazon_clone/constant/global.dart';
import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/utils/errorHandler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  Future<bool> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
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

          // Update user provider
          if (context.mounted) {
            // Make sure to wait for the provider update to complete
            await Provider.of<UserProvider>(context, listen: false)
                .setUser(jsonEncode(userData));

            // Add this critical line:
            await fetchUserData(context); // Fetches complete user profile

            showSnackBar(context, "Logged in Successfully!");
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, BottomNavBar.routeName, (route) => false);
            }
            return true;
          }
        } else {
          showSnackBar(context, "Login failed - no token received");
        }
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Login failed';
        showSnackBar(context, errorMessage);
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      showSnackBar(context, "An error occurred during login");
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

      // Add basic token expiration check if your token includes expiration
      // This is a simple example - your actual implementation may differ
      // based on your token structure

      try {
        // If your token is a JWT, you can do a basic check
        // This is a very basic check - not a full JWT validation
        final parts = token.split('.');
        if (parts.length != 3) {
          return false; // Not a valid JWT format
        }

        // Decode the payload part (middle part)
        String normalizedPayload = base64Url.normalize(parts[1]);
        Map<String, dynamic> payload =
            json.decode(utf8.decode(base64Url.decode(normalizedPayload)));

        // Check if token has expiration claim
        if (payload.containsKey('exp')) {
          int expiry = payload['exp'];
          int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          if (now >= expiry) {
            // Token has expired
            return false;
          }
        }
      } catch (e) {
        print("Token parsing error: $e");
        // If there's any error parsing the token, assume it's invalid
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

      // If token is valid, fetch user data
      await fetchUserData(context);
      return true;
    } catch (e) {
      print("Token validation error: $e");
      await _clearAuthData(context);
      return false;
    }
  }

  Future<void> fetchUserData(BuildContext context) async {
    try {
      print("Starting fetchUserData");
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      print(
          "Token from prefs: ${token?.substring(0, 10)}..."); // Print first 10 chars for debugging

      if (token == null || token.isEmpty) {
        print("No token found, clearing auth data");
        await _clearAuthData(context);
        return;
      }

      String uri = GlobalVariables.baseUrl;

      // First validate token
      print("Validating token");
      final tokenRes = await http.post(
        Uri.parse("$uri/caauth/validatetokenApp"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'token': token,
        },
      );

      print("Token validation response status: ${tokenRes.statusCode}");
      print("Token validation response body: ${tokenRes.body}");

      if (tokenRes.statusCode != 200) {
        print("Token validation failed with status: ${tokenRes.statusCode}");
        await _clearAuthData(context);
        return;
      }

      final bool isValid = jsonDecode(tokenRes.body);
      if (!isValid) {
        print("Token is not valid");
        await _clearAuthData(context);
        return;
      }

      // If token is valid, fetch user data
      print("Token is valid, fetching user data");
      final userRes = await http.get(
        Uri.parse("$uri/caauth/getUserApp"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'token': token,
        },
      );

      print("User data response status: ${userRes.statusCode}");

      if (userRes.statusCode == 200) {
        final userData = jsonDecode(userRes.body);
        userData['token'] = token; // Ensure token is included

        print("User data fetched successfully");
        if (context.mounted) {
          await Provider.of<UserProvider>(context, listen: false)
              .setUser(jsonEncode(userData));
        }
      } else {
        print("Failed to fetch user data: ${userRes.statusCode}");
        await _clearAuthData(context);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      await _clearAuthData(context);
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      // First clear all auth data
      await _clearAuthData(context);

      // Show success message
      showSnackBar(context, "Logged out successfully");

      // Navigate to landing screen instead of auth screen
      if (context.mounted) {
        // This ensures we go back to the landing page first
        Navigator.pushNamedAndRemoveUntil(
            context,
            '/landing-screen', // Go to landing screen, not directly to auth
            (route) => false);
      }
    } catch (e) {
      print("Logout error: $e");
      showSnackBar(context, "An error occurred during logout");

      // Even if logout fails, try to clear auth data and redirect
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
      // Clear token
      await prefs.remove('token');
      // Clear any other auth-related data that might be stored
      await prefs.remove('user');
      await prefs.remove('userData');
      // Add any other auth-related keys that might be saved

      // Clear provider state
      if (context.mounted) {
        await Provider.of<UserProvider>(context, listen: false).clearUser();
        // Don't call notifyListeners directly from outside the provider class
      }
    } catch (e) {
      print("Error clearing auth data: $e");
    }
  }
}
