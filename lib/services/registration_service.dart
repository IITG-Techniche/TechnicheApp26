import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/registration_model.dart';

class RegistrationService {
  static const String baseUrl = "https://technothlon.techniche.org.in/api";

  // POST /register
  static Future<Map<String, dynamic>> registerTeam(
      TecnoTeamRegistration  team) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(team.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Should contain { paymentUrl: ... }
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error registering team: $e');
    }
  }

  // PUT /handlePayment
  static Future<Map<String, dynamic>> confirmPayment(
      String registrationId) async {
    final url = Uri.parse('$baseUrl/handlePayment');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "registrationId": registrationId,
          "paymentStatus": "success",
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to confirm payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }
}
