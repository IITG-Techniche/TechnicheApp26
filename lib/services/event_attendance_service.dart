import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/event_points_constants.dart';

class EventAttendanceService {
  /// Fetch list of Techniche events from custom app-backend
  static Future<http.Response> fetchEventsList(String token) async {
    final url = Uri.parse(EventPointsConstants.eventsList);
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Submit event check-in to custom backend
  static Future<http.Response> checkInToEvent({
    required String token,
    required String eventId,
    required String eventName,
    double? latitude,
    double? longitude,
    bool faceVerified = true,
    int points = 150,
  }) async {
    final url = Uri.parse(EventPointsConstants.eventCheckin);
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eventId': eventId,
        'eventName': eventName,
        'latitude': latitude,
        'longitude': longitude,
        'faceVerified': faceVerified,
        'points': points,
      }),
    );
  }

  /// Fetch attendee's total points and history
  static Future<http.Response> fetchUserPoints(String token) async {
    final url = Uri.parse(EventPointsConstants.userPoints);
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Fetch redeemable rewards catalog
  static Future<http.Response> fetchRewardsCatalog(String token) async {
    final url = Uri.parse(EventPointsConstants.rewardsCatalog);
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Redeem reward item (e.g. Comedy Night Pass)
  static Future<http.Response> redeemReward({
    required String token,
    required String rewardId,
  }) async {
    final url = Uri.parse(EventPointsConstants.redeemReward);
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'rewardId': rewardId,
      }),
    );
  }
}
