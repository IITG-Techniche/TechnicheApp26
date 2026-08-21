import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/comedy_constants.dart';

class UserService {
  static const String _baseUrl = ComedyConstants.baseUrl;

  /// Authenticate user via Google login endpoint in microservice
  static Future<http.Response> loginWithGoogle({
    required String email,
    required String googleId,
    String? name,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/google-login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'googleId': googleId,
        'name': name ?? '',
      }),
    );
  }

  /// Authenticate user via Apple login endpoint in microservice
  static Future<http.Response> loginWithApple({
    required String appleId,
    String? email,
    String? name,
    String? identityToken,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/apple-login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'appleId': appleId,
        'email': email,
        'name': name,
        'identityToken': identityToken,
      }),
    );
  }

  /// Request user account deletion (App Store Guideline 5.1.1(v) compliance)
  static Future<http.Response> deleteAccount(String token) async {
    final url = Uri.parse('$_baseUrl/profile');
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Save Firebase Cloud Messaging token for push notifications
  static Future<http.Response> saveFcmToken({
    required String fcmToken,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/fcm-token');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fcmToken': fcmToken,
      }),
    );
  }

  /// Retrieve the user profile status/details
  static Future<http.Response> getProfile(String token) async {
    final url = Uri.parse('$_baseUrl/profile');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Update or Create user profile
  static Future<http.Response> updateProfile({
    required String name,
    required String rollNumber,
    required String collegeEmail,
    required String year,
    required String branch,
    required String program,
    required String phone,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/profile');
    final headers = {
      'Content-Type': 'application/json',
      'token': token,
      'Authorization': 'Bearer $token',
    };
    int parsedYear = 1;
    final cleanYear = year.toLowerCase();
    if (cleanYear.contains('1')) {
      parsedYear = 1;
    } else if (cleanYear.contains('2')) {
      parsedYear = 2;
    } else if (cleanYear.contains('3')) {
      parsedYear = 3;
    } else if (cleanYear.contains('4')) {
      parsedYear = 4;
    } else if (cleanYear.contains('5')) {
      parsedYear = 5;
    } else {
      parsedYear = int.tryParse(year) ?? 1;
    }

    final requestBody = jsonEncode({
      'name': name,
      'rollNumber': rollNumber,
      'collegeEmail': collegeEmail,
      'year': parsedYear,
      'branch': branch,
      'program': program,
      'phone': phone,
    });

    print("updateProfile URL: $url");
    print("updateProfile Headers: $headers");
    print("updateProfile Body: $requestBody");

    return await http.post(
      url,
      headers: headers,
      body: requestBody,
    );
  }
}
