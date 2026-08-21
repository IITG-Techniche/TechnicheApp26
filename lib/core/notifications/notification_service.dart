import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../model/events_data.dart';
import '../../view/eventdetailpage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState>? navigatorKey;
  bool _isInitialized = false;

  static const String reminderChannelId = 'event_reminders_channel';
  static const String reminderChannelName = 'Event Reminders';
  static const String reminderChannelDesc =
      'Offline reminders for Techniche events and workshops';

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize Timezones
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {
      // Fallback if Asia/Kolkata isn't available
    }

    // 2. Android Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Initialization Settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. Initialize Local Notifications Plugin with Tap Handler
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
    );

    // 5. Create Android High Importance Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      reminderChannelId,
      reminderChannelName,
      description: reminderChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;

    // Check if app was launched by tapping a notification
    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      if (payload != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationPayload(payload);
        });
      }
    }
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(
      NotificationResponse notificationResponse) {
    // Handle background notification tap if needed
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _handleNotificationPayload(payload);
    }
  }

  void _handleNotificationPayload(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      if (data['type'] == 'event_reminder') {
        final eventId = data['eventId'] as String?;
        if (eventId != null && eventId.isNotEmpty) {
          final event = findEventById(eventId) ?? findEventByTitle(eventId);
          if (event != null && navigatorKey?.currentState != null) {
            navigatorKey!.currentState!.push(
              MaterialPageRoute(
                builder: (_) => EventDetailPage(
                  eventTitle: event.title,
                  event: event,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling notification payload: $e');
    }
  }

  Future<bool> requestPermission() async {
    bool isGranted = false;

    // 1. Android Permission Request
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      isGranted = granted ?? false;
    }

    // 2. iOS Permission Request
    final iosImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      isGranted = isGranted || (granted ?? false);
    }

    // 3. System Permission Handler Fallback / Confirmation
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final requested = await Permission.notification.request();
      isGranted = requested.isGranted;
    } else {
      isGranted = true;
    }

    return isGranted;
  }

  Future<void> schedule({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    await initialize();

    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    // Verify time is in the future
    if (!tzScheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      debugPrint('Cannot schedule notification in the past: $tzScheduledTime');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      reminderChannelId,
      reminderChannelName,
      channelDescription: reminderChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint(
          '✅ Notification scheduled successfully for $title at $tzScheduledTime (ID: $notificationId)');
    } catch (e) {
      debugPrint(
          'Falling back to inexact notification scheduling due to: $e');
      await _localNotifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  Future<void> cancel(int notificationId) async {
    await initialize();
    await _localNotifications.cancel(notificationId);
    debugPrint('🗑️ Notification cancelled (ID: $notificationId)');
  }

  Future<void> cancelAll() async {
    await initialize();
    await _localNotifications.cancelAll();
  }
}
