import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techniche26/constant/global.dart';

class CaApiService {
  static const String baseUrl = GlobalVariables.baseUrl;

  /// Register a new Campus Ambassador
  static Future<http.Response> register({
    required String name,
    required String email,
    required String contact,
    required String institution,
    required String city,
    required String state,
    required String password,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/caauth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'contact': contact,
        'institution': institution,
        'city': city,
        'state': state,
        'password': password,
      }),
    );
  }

  /// Request a password reset link
  static Future<http.Response> forgotPassword(String email) async {
    return await http.post(
      Uri.parse('$baseUrl/caauth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  /// Fetch CA user profile details (Points, Institution, City, State, etc.)
  /// Uses the Dashboard endpoint as recommended by the user for reliability.
  static Future<Map<String, dynamic>?> getCaUserDetails(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/catasksupload/getuserdetails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error in getCaUserDetails: $e");
      return null;
    }
  }

  /// Sign in a Campus Ambassador
  static Future<http.Response> signIn(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/caauth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  /// Fetch tasks for a specific CA
  static Future<http.Response> fetchTasks(String email) async {
    return await http.post(
      Uri.parse('$baseUrl/catasksupload/showusertasksupdated'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'params': {'email': email}
      }),
    );
  }

  /// Fetch global CA leaderboard
  static Future<http.Response> fetchLeaderboard() async {
    return await http.get(Uri.parse('$baseUrl/catasksupload/leaderboard'));
  }

  /// Submit a task link
  static Future<http.Response> submitTask(String email, String taskId, String link) async {
    return await http.post(
      Uri.parse('$baseUrl/catasksupload/submitTaskByUser'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'taskId': taskId,
        'link': link,
        'params': {'email': email}
      }),
    );
  }

  /// Update task as 'done' after submission
  static Future<http.Response> updateTaskStatus(String email, String taskId) async {
    return await http.put(
      Uri.parse('$baseUrl/catasksupload/updateDoneInCATask'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'taskId': taskId,
        'params': {'email': email}
      }),
    );
  }

  /// Resubmit a corrected link for a rejected task
  static Future<http.Response> resubmitTask(String email, String taskId, String link) async {
    return await http.put(
      Uri.parse('$baseUrl/catasksupload/submitCorrectLinkByUser'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'taskId': taskId,
        'link': link,
        'email': email,
      }),
    );
  }
}
