import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase.initializeApp in background

// This handler is called when the app is in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp` before using other Firebase services.
  // It's good practice to ensure it's initialized here if this handler might be
  // the first entry point for Firebase in a background isolate.
  await Firebase.initializeApp(); // Ensure Firebase is initialized in this isolate.

  print("BACKGROUND HANDLER: Message received!");
  print("BACKGROUND HANDLER: Message ID: ${message.messageId}");
  print("BACKGROUND HANDLER: Notification Title: ${message.notification?.title}");
  print("BACKGROUND HANDLER: Notification Body: ${message.notification?.body}");
  print("BACKGROUND HANDLER: Data payload: ${message.data}");

  // For "notification" messages received when the app is in the background or terminated,
  // FCM automatically displays the notification in the system tray.
  // This handler is called when the message is received, not necessarily when it's tapped.
  // If you need to show a custom local notification for background messages (e.g. for data-only messages),
  // you would initialize and use flutter_local_notifications here.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  bool _permissionDenied = false;
  bool _isInitialized = false;
  DateTime _lastTokenRefresh = DateTime.now();
  
  bool get permissionDenied => _permissionDenied;
  bool get isInitialized => _isInitialized;
  
  // Initialize notification channels and request permissions
  Future<void> initNotifications({bool subscribeToTopics = false}) async {
    if (_isInitialized) {
      print("NotificationService: Already initialized, skipping initialization");
      return;
    }

    print("NotificationService: Beginning initialization");
    
    // Set our debug message listener early to catch any incoming messages
    _setDebugMessageListener();
    
    // Request permission
    final permissionStatus = await _checkNotificationPermissionStatus();
    
    if (permissionStatus == PermissionStatus.granted) {
      await _setupNotificationServices(subscribeToTopics: subscribeToTopics);
      _isInitialized = true;
    } else {
      _permissionDenied = true;
      print("Notification permission denied or restricted. FCM functionality limited.");
      // Still try to get token, but notifications won't show
      await _getAndStoreToken();
      
      // Try requesting permission right away
      final granted = await _requestNotificationPermissions();
      if (granted) {
        await _setupNotificationServices(subscribeToTopics: subscribeToTopics);
        _isInitialized = true;
      }
    }
    
    print("NotificationService: Initialization complete. Permission denied: $_permissionDenied");
    
    // Diagnostics information
    _printNotificationDiagnostics();
  }

  // Print diagnostics about the notification setup
  Future<void> _printNotificationDiagnostics() async {
    try {
      print("\n========== FULL FCM DIAGNOSTICS ==========");
      print("FCM Token: $_fcmToken");
      print("Token Length: ${_fcmToken?.length ?? 0}");
      print("Last Token Refresh: $_lastTokenRefresh");
      print("Permission Denied: $_permissionDenied");
      print("Is Initialized: $_isInitialized");
      print("----------------------------------------");
      print("Notification Channels:");
      final channels = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.getNotificationChannels();
      if (channels != null) {
        for (var channel in channels) {
          print("  - ${channel.id} (${channel.name})");
        }
      }
      print("========== END FCM DIAGNOSTICS ==========\n");
    } catch (e) {
      print("Diagnostics Error: $e");
    }
  }
  
  // Set up debug listener to monitor incoming messages
  void _setDebugMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("\n========== FCM MESSAGE RECEIVED ==========");
      print("Message ID: ${message.messageId}");
      print("Sent Time: ${message.sentTime}");
      print("TTL: ${message.ttl}");
      // print("Priority: ${message.priority}");
      print("----------------------------------------");
      if (message.notification != null) {
        print("NOTIFICATION:");
        print("  Title: ${message.notification!.title}");
        print("  Body: ${message.notification!.body}");
        if (message.notification!.android != null) {
          print("  Android Channel: ${message.notification!.android?.channelId}");
          print("  Android Priority: ${message.notification!.android?.priority}");
        }
      }
      print("----------------------------------------");
      if (message.data.isNotEmpty) {
        print("DATA PAYLOAD:");
        message.data.forEach((key, value) {
          print("  $key: $value");
        });
      }
      print("========== END MESSAGE ==========\n");
    });
  }
  
  // Check current permission status
  Future<PermissionStatus> _checkNotificationPermissionStatus() async {
    final status = await Permission.notification.status;
    print("Current notification permission status: $status");
    return status;
  }
  
  // Request permission to show notifications
  Future<bool> _requestNotificationPermissions() async {
    try {
      final status = await Permission.notification.request();
      print("Notification permission request result: $status");
      
      if (status.isGranted) {
        // Request FCM authorization for iOS
        NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        
        print('FCM authorization status: ${settings.authorizationStatus}');
        
        // If permissions were previously denied but now granted
        if (_permissionDenied) {
          _permissionDenied = false;
        }
        
        return true;
      } else {
        _permissionDenied = true;
        return false;
      }
    } catch (e) {
      print("Error requesting notification permissions: $e");
      return false;
    }
  }
  
  // Setup notification services after permissions are granted
  Future<void> _setupNotificationServices({bool subscribeToTopics = false}) async {
    print("NotificationService: Setting up notification services");
    
    // Set up foreground notification presentation options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    
    // Initialize local notifications with channel
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create the notification channel for Android
    await _createNotificationChannel();
    
    // Set up handlers for different notification scenarios
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    // Register background handler globally
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Get the token for this device
    await _getAndStoreToken();

    // Only subscribe to topics if explicitly requested (avoid the topic sync error)
    if (subscribeToTopics) {
      await _subscribeToDefaultTopics();
    }
    
    print("NotificationService: Setup completed successfully");
  }

  // Subscribe to default topics - separated to handle errors gracefully
  Future<void> _subscribeToDefaultTopics() async {
    try {
      // Wait a moment before subscribing
      await Future.delayed(const Duration(seconds: 2));
      
      // Try to subscribe with better error handling
      final success = await subscribeToTopic('all_users');
      if (success) {
        print("Successfully subscribed to default topics");
      } else {
        print("Failed to subscribe to default topics");
      }
    } catch (e) {
      print("Error in _subscribeToDefaultTopics: $e");
    }
  }

  // Create notification channel - this is crucial for Android notifications to work
  Future<void> _createNotificationChannel() async {
    try {
      // Define the channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',    // Change from default_notification_channel
        'High Importance Notifications', // Change from Default Channel
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      );

      // Create the channel
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      print("Channel created: ${channel.id}");
    } catch (e) {
      print("Channel creation failed: $e");
    }
  }
  
  // Show dialog to request notification permission
  Future<void> showPermissionRequestDialog(BuildContext context) async {
    if (_permissionDenied) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
              'Notifications are currently disabled. Would you like to enable them to receive important updates?'
            ),
            actions: [
              TextButton(
                child: const Text('Not Now'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enable'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // First try the in-app permission request
                  final granted = await _requestNotificationPermissions();
                  
                  // If still denied, open app settings
                  if (!granted) {
                    await openAppSettings();
                  } else {
                    // If permissions now granted, set up notifications
                    await _setupNotificationServices();
                    _isInitialized = true;
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
  
  // Get FCM token and store it
  Future<void> _getAndStoreToken() async {
    try {
      // Request permissions first
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken = token;
        _lastTokenRefresh = DateTime.now();
        print("\n========== FCM TOKEN DETAILS ==========");
        print("Token: $token");
        print("Token Length: ${token.length}");
        print("Refresh Time: $_lastTokenRefresh");
        print("========== END TOKEN DETAILS ==========\n");
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
      } else {
        print("ERROR: FCM token is null");
      }
    } catch (e) {
      print("TOKEN ERROR: $e");
    }
  }
  
  // Get token (for internal use only)
  Future<String?> getDeviceToken() async {
    if (_fcmToken != null) return _fcmToken;
    
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        _lastTokenRefresh = DateTime.now();
        print("FCM Token (Device ID) from getDeviceToken: $_fcmToken");
      }
      return _fcmToken;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }
  
  // Handle initial message (app opened from terminated state by notification)
  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      print("Application opened from terminated state with message: ${message.notification?.title}");
      // Navigate to specific page based on notification data if needed
    }
  }
  
  // Handle foreground messages (app is open) - with improved logging and error handling
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      print("\n==== FOREGROUND MESSAGE RECEIVED ====");
      print("Message ID: ${message.messageId}");
      print("Message Time: ${message.sentTime}");
      print("Notification Title: ${message.notification?.title}");
      print("Notification Body: ${message.notification?.body}");
      print("Data payload: ${message.data}");
      
      if (message.notification != null) {
        print("Showing local notification for foreground message");
        _showLocalNotification(message);
      } else if (message.data.isNotEmpty) {
        // Handle data-only messages
        print("Message has no notification but has data payload. Showing data notification.");
        _showLocalNotificationFromData(message.data);
      } else {
        print("Foreground message has no notification or data payload. Not showing local notification.");
      }
      print("==== END FOREGROUND MESSAGE HANDLING ====\n");
    } catch (e) {
      print("Error handling foreground message: $e");
    }
  }
  
  // Handle when user taps on notification that opened the app from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print("App opened from background state with message: ${message.notification?.title}");
    // Navigate to specific page based on notification data if needed
  }
  
  // Handle notification response (when user taps on local notification)
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print("Local notification tapped: ${response.payload}");
    // Navigate based on payload if needed
  }
  
  // Show a local notification from a RemoteMessage
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_notification_channel', // Must match channel ID above
              'Default Channel',
              channelDescription: 'Default notification channel for all messages',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              enableVibration: true,
              channelShowBadge: true,
              visibility: NotificationVisibility.public,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
        print("Local notification shown successfully: ${notification.title}");
      }
    } catch (e) {
      print("Error showing local notification: $e");
    }
  }

  // Show local notification from data payload (for data-only messages)
  Future<void> _showLocalNotificationFromData(Map<String, dynamic> data) async {
    try {
      final String title = data['title'] ?? 'New Notification';
      final String body = data['body'] ?? 'You have a new notification';
      final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: data['route'],
      );
      print("  Data-only notification shown successfully with ID: $notificationId");
    } catch (e) {
      print("  Error showing data-only notification: $e");
    }
  }
  
  // Subscribe to a topic (for topic-based notifications) with error handling
  Future<bool> subscribeToTopic(String topic) async {
    try {
      print("\n===== SUBSCRIBING TO TOPIC =====");
      // Ensure we have a valid token
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        print("No valid token, attempting reset...");
        await resetFcmToken();
        if (_fcmToken == null) {
          print("Failed to obtain valid token for subscription");
          return false;
        }
      }

      // Add delay before subscription
      await Future.delayed(const Duration(seconds: 3));
      
      print("Attempting to subscribe to topic: $topic");
      print("Using token: ${_fcmToken!.substring(0, 10)}...");
      
      await _firebaseMessaging.subscribeToTopic(topic);
      print("Successfully subscribed to topic: $topic");
      print("===== SUBSCRIPTION COMPLETE =====\n");
      return true;
    } catch (e) {
      print("ERROR subscribing to topic: $e");
      return false;
    }
  }
  
  // Unsubscribe from a topic with error handling
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
      return true;
    } catch (e) {
      print('Failed to unsubscribe from topic: $topic - Error: $e');
      return false;
    }
  }
  
  // Delete all topic subscriptions (useful when syncing topics fails)
  Future<bool> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print("FCM token deleted - this will remove all topic subscriptions");
      return true;
    } catch (e) {
      print("Error deleting FCM token: $e");
      return false;
    }
  }
  
  // Test notification - use this method to send a test notification
  Future<void> showTestNotification() async {
    try {
      print("\n=== SENDING TEST NOTIFICATION ===");
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel', // Must match channel ID above
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        'Test Notification',
        'This is a test notification sent at ${DateTime.now()}',
        platformDetails,
      );
      
      print("SUCCESS: Test notification sent with ID: $id");
      print("=== END TEST NOTIFICATION ===\n");
      
    } catch (e) {
      print("ERROR: Failed to send test notification: $e");
    }
  }
  
  // Reset FCM token - useful for testing
  Future<void> resetFcmToken() async {
    try {
      print("\n===== STARTING FCM TOKEN RESET =====");
      
      // Delete existing token
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print("Old FCM Token deleted");
      
      // Wait before requesting new token
      await Future.delayed(const Duration(seconds: 2));
      
      // Request a new token with multiple attempts
      int attempts = 0;
      while (_fcmToken == null && attempts < 3) {
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken == null) {
          attempts++;
          print("Token request attempt $attempts failed, retrying...");
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      
      if (_fcmToken != null) {
        _lastTokenRefresh = DateTime.now();
        print("\nNEW FCM TOKEN DETAILS:");
        print("Token: $_fcmToken");
        print("Length: ${_fcmToken!.length}");
        print("Generated at: $_lastTokenRefresh");
        
        // Store new token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', _fcmToken!);
        print("Token stored in SharedPreferences");
      } else {
        print("ERROR: Failed to obtain new FCM token after multiple attempts");
      }
      
      print("===== FCM TOKEN RESET COMPLETE =====\n");
    } catch (e) {
      print("ERROR during FCM token reset: $e");
    }
  }
}
