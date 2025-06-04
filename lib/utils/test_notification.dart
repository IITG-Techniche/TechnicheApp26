import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestNotification {
  static Future<void> sendTestNotification(BuildContext context) async {
    try {
      // Get the stored FCM token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcmToken');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FCM token not found')),
        );
        return;
      }

      // Your Firebase project's server key from Firebase Console
      const serverKey = 'YOUR_SERVER_KEY'; // Replace with your server key

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'notification': {
            'title': 'Test Notification',
            'body': 'This is a test notification',
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type': 'test',
          },
          'to': token,
        }),
      );

      print('FCM Test Response: ${response.statusCode}');
      print('FCM Test Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test notification sent successfully')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send test notification: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Error sending test notification: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
