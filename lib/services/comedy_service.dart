import 'package:http/http.dart' as http;
import '../constant/comedy_constants.dart';

class ComedyService {
  static const String _baseUrl = ComedyConstants.baseUrl;

  /// Check comedy registration status and details
  static Future<http.Response> checkComedyStatus(String token) async {
    final url = Uri.parse('$_baseUrl/comedy/status');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Register for the Comedy Night event
  static Future<http.Response> registerComedy(String token) async {
    final url = Uri.parse('$_baseUrl/comedy/register');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }
}
