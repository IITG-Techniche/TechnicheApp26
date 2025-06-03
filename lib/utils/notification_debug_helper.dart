import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_clone/services/notification_service.dart';

class NotificationDebugHelper {
  static final NotificationDebugHelper _instance = NotificationDebugHelper._internal();
  
  factory NotificationDebugHelper() => _instance;
  
  NotificationDebugHelper._internal();

  /// Verify if an FCM token is valid by attempting to send a test message
  Future<bool> verifyFcmToken(String fcmToken) async {
    try {
      bool success = await _sendTestMessageViaApi(fcmToken);
      return success;
    } catch (e) {
      print("Error verifying FCM token: $e");
      return false;
    }
  }

  /// Send a direct message to the device using FCM HTTP v1 API
  Future<bool> _sendTestMessageViaApi(String token) async {
    // You'll need to replace this with your Firebase server key
    // Get it from Firebase Console -> Project Settings -> Cloud Messaging -> Server key
    const String serverKey = 'YOUR_SERVER_KEY'; // Replace with actual server key
    
    if (serverKey == 'YOUR_SERVER_KEY') {
      print("ERROR: You need to replace the server key in notification_debug_helper.dart");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/techniche-269b1/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(
          {
            'message': {
              'token': token,
              'notification': {
                'title': 'FCM Token Test',
                'body': 'This is a test message sent directly from the app',
              },
              'android': {
                'notification': {
                  'channel_id': 'high_importance_channel',
                }
              },
              'data': {
                'type': 'test',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK'
              }
            }
          },
        ),
      );

      print("FCM API Response Status: ${response.statusCode}");
      print("FCM API Response Body: ${response.body}");
      
      return response.statusCode == 200;
    } catch (e) {
      print("Error sending message via FCM API: $e");
      return false;
    }
  }

  /// Check common FCM issues and print diagnostic information
  Future<Map<String, dynamic>> diagnoseFcmIssues() async {
    Map<String, dynamic> results = {
      'tokenExists': false,
      'permissionsGranted': false,
      'channelExists': false,
      'testNotificationWorks': false,
      'issues': <String>[],
    };

    try {
      final notificationService = NotificationService();
      
      // Check if token exists
      final fcmToken = await notificationService.getDeviceToken();
      results['tokenExists'] = fcmToken != null && fcmToken.isNotEmpty;
      results['token'] = fcmToken;
      
      if (!results['tokenExists']) {
        results['issues'].add('FCM token is missing or empty');
      }

      // Check notification permissions
      results['permissionsGranted'] = !notificationService.permissionDenied;
      if (!results['permissionsGranted']) {
        results['issues'].add('Notification permissions are not granted');
      }

      // Test sending a local notification
      try {
        await notificationService.showTestNotification();
        results['testNotificationWorks'] = true;
      } catch (e) {
        results['testNotificationWorks'] = false;
        results['issues'].add('Local notification test failed: $e');
      }

      // Additional system info that might be helpful
      results['androidInfo'] = await _getAndroidDeviceInfo();
      
      if (results['issues'].isEmpty) {
        results['issues'].add('No obvious issues detected. If notifications still don\'t work, check Firebase Console configuration.');
      }
      
      return results;
    } catch (e) {
      print("Error diagnosing FCM issues: $e");
      results['issues'].add('Error during diagnosis: $e');
      return results;
    }
  }

  /// Get Android device info for troubleshooting
  Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    try {
      // For a complete implementation, you would use device_info_plus package
      // This is a simplified version
      return {
        'manufacturer': 'unknown',
        'model': 'unknown',
        'androidVersion': 'unknown',
        'sdkInt': 'unknown',
      };
    } catch (e) {
      print("Error getting device info: $e");
      return {};
    }
  }

  /// Display a comprehensive FCM debug dialog
  void showFcmDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FCM Diagnostic Tool'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: diagnoseFcmIssues(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            final results = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusItem('FCM Token Exists', results['tokenExists']),
                  _buildStatusItem('Permissions Granted', results['permissionsGranted']),
                  _buildStatusItem('Local Notifications Work', results['testNotificationWorks']),
                  const Divider(),
                  const Text('FCM Token:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(results['token'] ?? 'Not available', 
                    style: const TextStyle(fontSize: 12)),
                  const Divider(),
                  const Text('Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(
                    (results['issues'] as List).length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(results['issues'][index])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Testing Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildTestingStep('1', 'Verify your server key in Firebase Console'),
                  _buildTestingStep('2', 'Try sending message from Firebase Console'),
                  _buildTestingStep('3', 'Check for any Firebase restrictions'),
                  _buildTestingStep('4', 'Ensure device has internet connectivity'),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text("Resetting FCM connection..."),
                      ],
                    ),
                  );
                },
              );
              
              // Reset FCM connection
              await NotificationService().resetFcmToken();
              
              if (context.mounted) {
                Navigator.pop(context); // Dismiss loading
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FCM connection reset completed')),
                );
              }
            },
            child: const Text('Reset FCM Connection'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusItem(String label, bool value) {
    return Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.error_outline,
          color: value ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          value ? 'OK' : 'Issue',
          style: TextStyle(
            color: value ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTestingStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(instruction)),
        ],
      ),
    );
  }
}
