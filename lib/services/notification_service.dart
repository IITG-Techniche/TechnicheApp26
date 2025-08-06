import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// The main method to call on app startup.
  Future<void> initializeAndHandleNotifications() async {
    print("--- Starting Notification Setup ---");

    // 1. Initialize Local Notifications and Create Channel
    // This must be done before handling messages to ensure the channel exists.
    await _initializeLocalNotifications();

    // 2. Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // 3. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 4. Check for notification permission
    PermissionStatus status = await Permission.notification.status;
    print("Current notification permission status: $status");

    if (!status.isGranted) {
      print("Permission not granted. Requesting now...");
      status = await Permission.notification.request();
      print("Permission request result: $status");
    }

    if (status.isGranted) {
      print("Permission is granted. Proceeding with token and subscription.");
      await _getTokenAndSubscribe();
    } else {
      print("Permission denied. Cannot get token or subscribe to topics.");
    }

    print("--- Notification Setup Complete ---");
  }

  /// Initializes the local notifications plugin and creates the necessary Android channel.
  Future<void> _initializeLocalNotifications() async {
    // Define the channel. The ID MUST match the one in AndroidManifest.xml
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    // Create the channel on the device
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);
  }

  /// Handles messages that arrive while the app is in the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    print("Foreground message received: ${message.notification?.title}");
    final notification = message.notification;
    if (notification != null) {
      // Manually display a local notification.
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel Name
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  /// Gets the FCM token, stores it, and subscribes to the 'all_users' topic.
  Future<void> _getTokenAndSubscribe() async {
    try {
      final String? token = await _fcm.getToken();
      if (token != null) {
        print("\n✅ FCM TOKEN: $token\n");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        print("✅ Token successfully stored in SharedPreferences.");
        await _fcm.subscribeToTopic('all_users');
        print("✅ Successfully subscribed to 'all_users' topic.");
      } else {
        print("❌ ERROR: Failed to get FCM token. It was null.");
      }
    } catch (e) {
      print("❌ ERROR during token/subscription process: $e");
    }
  }
}
