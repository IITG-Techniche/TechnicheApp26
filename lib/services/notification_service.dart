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
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeAndHandleNotifications() async {
    await _initializeLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
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

  Future<void> _initializeLocalNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _localNotifications.initialize(initializationSettings);
  }

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
