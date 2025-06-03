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
      print("\n======= NOTIFICATION DIAGNOSTICS =======");
      print("FCM Token: $_fcmToken");
      print("Permission Denied: $_permissionDenied");
      print("Is Initialized: $_isInitialized");
      print("Last Token Refresh: $_lastTokenRefresh");
      
      try {
        // Check notification settings on iOS
        if (Theme.of(GlobalKey<NavigatorState>().currentContext!).platform == TargetPlatform.iOS) {
          final settings = await _firebaseMessaging.getNotificationSettings();
          print("iOS Authorization Status: ${settings.authorizationStatus}");
          print("iOS Alert Setting: ${settings.alert}");
          print("iOS Badge Setting: ${settings.badge}");
          print("iOS Sound Setting: ${settings.sound}");
        }
      } catch (e) {
        print("Error getting iOS settings: $e");
      }
      
      try {
        // Check APNs token on iOS
        if (Theme.of(GlobalKey<NavigatorState>().currentContext!).platform == TargetPlatform.iOS) {
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          print("APNS Token: $apnsToken");
        }
      } catch (e) {
        print("Error getting APNS token: $e");
      }

      print("======= END DIAGNOSTICS =======\n");
    } catch (e) {
      print("Error printing diagnostics: $e");
    }
  }
  
  // Set up debug listener to monitor incoming messages
  void _setDebugMessageListener() {
    // Listen for incoming messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("\n👉 DEBUG: RECEIVED MESSAGE IN FOREGROUND");
      print("👉 DEBUG: Message ID: ${message.messageId}");
      print("👉 DEBUG: Sent Time: ${message.sentTime}");
      print("👉 DEBUG: TTL: ${message.ttl}");
      
      if (message.notification != null) {
        print("👉 DEBUG: NOTIFICATION DATA:");
        print("👉 DEBUG: Title: ${message.notification!.title}");
        print("👉 DEBUG: Body: ${message.notification!.body}");
      } else {
        print("👉 DEBUG: No notification payload");
      }
      
      if (message.data.isNotEmpty) {
        print("👉 DEBUG: DATA PAYLOAD: ${message.data}");
      } else {
        print("👉 DEBUG: No data payload");
      }
      
      // Will be handled by the regular onMessage listener too
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
      // Explicitly subscribe to the 'all_users' topic to match backend sending
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print("NotificationService: Successfully subscribed to topic 'all_users'");
    } catch (e) {
      // Just log the error without breaking the initialization process
      print("NotificationService: Failed to subscribe to topic 'all_users': $e");
      print("NotificationService: Topic subscription skipped - this won't affect receiving direct notifications");
    }
  }

  // Create notification channel - this is crucial for Android notifications to work
  Future<void> _createNotificationChannel() async {
    try {
      const androidNotificationChannel = AndroidNotificationChannel(
        'high_importance_channel', // Channel ID
        'High Importance Notifications', // Channel name
        description: 'This channel is used for important notifications.', // Channel description
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
      
      print("NotificationService: Created Android notification channel successfully");
    } catch (e) {
      print("NotificationService: Failed to create notification channel: $e");
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
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _fcmToken = token;
        _lastTokenRefresh = DateTime.now();
        print("FCM Token (Device ID): $_fcmToken");
        print("FCM Token Length: ${token.length}");
        print("FCM Token First 10 chars: ${token.substring(0, 10)}...");
        
        // Store token in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
        
        // TODO: Send this token to your server to associate with the user
      } else {
        print("Failed to get FCM token");
      }
      
      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        _lastTokenRefresh = DateTime.now();
        print("FCM Token Refreshed (Device ID): $_fcmToken");
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', newToken);
        
        // TODO: Send the new token to your server
      });
    } catch (e) {
      print("Error getting FCM token: $e");
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
    final RemoteNotification? notification = message.notification; 
    final AndroidNotification? android = message.notification?.android; // For logging

    print("_showLocalNotification: Attempting to show local notification.");
    print("  Message ID: ${message.messageId}"); // Log message ID
    print("  Notification Title from RemoteMessage: ${notification?.title}"); 
    print("  Notification Body from RemoteMessage: ${notification?.body}");   
    if (android != null) {
      print("  Android Specifics from RemoteMessage: Exists (details like channelId: ${android.channelId})");
    } else {
      print("  Android Specifics from RemoteMessage: null (This is okay, we'll use default local notification settings)");
    }

    if (notification != null) { 
      print("  Condition (notification != null) is TRUE. Proceeding to show.");
      try {
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode, // Unique ID for the notification
          notification.title,
          notification.body,
          NotificationDetails(
            android: const AndroidNotificationDetails(
              'high_importance_channel', // Channel ID - must match channel created earlier
              'High Importance Notifications', // Channel Name
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              enableVibration: true,
              visibility: NotificationVisibility.public,
              // icon: '@mipmap/ic_launcher', // Ensure this icon exists if uncommented
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['route'], // Optional: data to pass when notification is tapped
        );
        print("  flutter_local_notifications.show() called successfully for notification ID: ${notification.hashCode}.");
      } catch (e) {
        print("  Error calling flutter_local_notifications.show(): $e");
      }
    } else {
      print("  Condition (notification != null) is FALSE. Local notification NOT shown.");
      print("    Reason: message.notification was null (unexpected at this point if called from _handleForegroundMessage).");
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
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
      return true;
    } catch (e) {
      print('Failed to subscribe to topic: $topic - Error: $e');
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
      print("Attempting to show test notification...");
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        channelShowBadge: true,
      );
      
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _flutterLocalNotificationsPlugin.show(
        id,
        'Test Notification',
        'This is a test notification sent at ${DateTime.now().toString()}',
        platformDetails,
      );
      
      print("Test notification sent successfully with ID: $id");
      return Future.value();
    } catch (e) {
      print("Error sending test notification: $e");
      return Future.error(e);
    }
  }
  
  // Reset FCM token - useful for testing
  Future<void> resetFcmToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print("FCM Token deleted");
      
      // Request a new token
      _fcmToken = await _firebaseMessaging.getToken();
      _lastTokenRefresh = DateTime.now();
      print("New FCM Token: $_fcmToken");
      
      // Store new token
      final prefs = await SharedPreferences.getInstance();
      if (_fcmToken != null) {
        await prefs.setString('fcmToken', _fcmToken!);
      } else {
        await prefs.remove('fcmToken');
      }
    } catch (e) {
      print("Error resetting FCM token: $e");
    }
  }
}
