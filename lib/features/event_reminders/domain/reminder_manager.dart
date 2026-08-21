import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:techniche26/core/notifications/notification_service.dart';
import 'package:techniche26/model/events_data.dart';
import 'package:techniche26/model/event_model.dart';
import '../data/reminder_repository.dart';
import 'event_reminder.dart';

class ReminderManager {
  static final ReminderManager _instance = ReminderManager._internal();
  factory ReminderManager() => _instance;
  ReminderManager._internal();

  final ReminderRepository _repository = ReminderRepository();
  final NotificationService _notificationService = NotificationService();

  /// Creates a unique deterministic integer notification ID from a stable string event ID.
  int _generateNotificationId(String eventId) {
    return eventId.hashCode.abs() % 2147483647;
  }

  /// Extracts the stable event ID from an EventDetail, Event, or string ID.
  String extractEventId(dynamic event) {
    if (event is EventDetail) {
      return event.effectiveId;
    } else if (event is Event) {
      return event.id;
    } else if (event is String) {
      return event;
    } else if (event is Map<String, dynamic>) {
      return event['id'] ?? event['eventId'] ?? event['title'] ?? 'event';
    }
    return event.toString();
  }

  /// Extracts the event title from an EventDetail, Event, or string.
  String extractEventTitle(dynamic event) {
    if (event is EventDetail) {
      return event.title;
    } else if (event is Event) {
      return event.name;
    } else if (event is Map<String, dynamic>) {
      return event['title'] ?? event['name'] ?? 'Event';
    }
    return event.toString();
  }

  /// Extracts the start DateTime from an EventDetail, Event, or map.
  DateTime? extractEventStartTime(dynamic event) {
    if (event is EventDetail) {
      return event.parsedStartDateTime;
    } else if (event is Event) {
      return event.date;
    } else if (event is Map<String, dynamic>) {
      if (event['date'] is DateTime) return event['date'];
      if (event['date'] is String) return DateTime.tryParse(event['date']);
      if (event['startTime'] is DateTime) return event['startTime'];
      if (event['startTime'] is int) {
        return DateTime.fromMillisecondsSinceEpoch(event['startTime']);
      }
    }
    return null;
  }

  /// Extracts venue string if available.
  String? extractVenue(dynamic event) {
    if (event is EventDetail) {
      return event.venue;
    } else if (event is Event) {
      return event.location;
    } else if (event is Map<String, dynamic>) {
      return event['venue'] ?? event['location'];
    }
    return null;
  }

  /// Creates and schedules a new reminder for an event.
  /// Returns `true` if scheduled successfully, or `false` if permission was denied,
  /// or if the reminder time is already in the past.
  Future<bool> createReminder({
    required dynamic event,
    required int offsetMinutes,
    DateTime? explicitStartTime,
  }) async {
    final eventId = extractEventId(event);
    final eventTitle = extractEventTitle(event);
    final eventStartTime =
        explicitStartTime ?? extractEventStartTime(event);

    if (eventStartTime == null) {
      debugPrint('❌ Cannot schedule reminder: Event start time is unknown.');
      return false;
    }

    final reminderTime = eventStartTime.subtract(
      Duration(minutes: offsetMinutes),
    );

    // Validate reminder time is strictly in the future
    if (!reminderTime.isAfter(DateTime.now())) {
      debugPrint(
          '❌ Cannot schedule reminder: Reminder time ($reminderTime) is in the past.');
      return false;
    }

    // Request notification permissions
    final hasPermission = await _notificationService.requestPermission();
    if (!hasPermission) {
      debugPrint('❌ Notification permission denied by user.');
      return false;
    }

    final notificationId = _generateNotificationId(eventId);

    // 1. Cancel existing notification if any (Avoid duplicates)
    await _notificationService.cancel(notificationId);

    // 2. Schedule local notification
    final venue = extractVenue(event);
    final venueText = (venue != null && venue.trim().isNotEmpty) ? ' at $venue' : '';
    final body = offsetMinutes == 0
        ? '$eventTitle is starting now$venueText!'
        : '$eventTitle starts in $offsetMinutes minutes$venueText!';

    final payload = jsonEncode({
      'type': 'event_reminder',
      'eventId': eventId,
    });

    await _notificationService.schedule(
      notificationId: notificationId,
      title: 'Techniche Reminder: $eventTitle',
      body: body,
      scheduledTime: reminderTime,
      payload: payload,
    );

    // 3. Save/Update reminder in SQLite
    final reminder = EventReminder(
      eventId: eventId,
      notificationId: notificationId,
      eventStartTime: eventStartTime,
      reminderTime: reminderTime,
      offsetMinutes: offsetMinutes,
      enabled: true,
    );

    await _repository.insertOrUpdate(reminder);
    debugPrint(
        '✅ Saved reminder in SQLite for $eventTitle at $reminderTime ($offsetMinutes min before)');
    return true;
  }

  /// Cancels and removes an existing reminder for an event.
  Future<void> removeReminder({required String eventId}) async {
    final existing = await _repository.getReminder(eventId);
    if (existing != null) {
      await _notificationService.cancel(existing.notificationId);
      await _repository.deleteReminder(eventId);
      debugPrint('🗑️ Removed reminder for eventId: $eventId');
    }
  }

  /// Retrieves an existing reminder from SQLite for a given event ID.
  Future<EventReminder?> getReminder(String eventId) async {
    return await _repository.getReminder(eventId);
  }

  /// Retrieves all active reminders stored in SQLite.
  Future<List<EventReminder>> getAllReminders() async {
    return await _repository.getAllReminders();
  }

  /// Synchronizes active reminders with fresh event data:
  /// - If event time changed -> Reschedules notification and updates SQLite.
  /// - If event cancelled/deleted -> Removes local reminder.
  Future<void> syncWithEvents(List<dynamic> events) async {
    final storedReminders = await _repository.getAllReminders();
    if (storedReminders.isEmpty) return;

    // Create a lookup map of incoming events by their stable ID
    final Map<String, dynamic> incomingEventMap = {};
    for (final ev in events) {
      final id = extractEventId(ev);
      incomingEventMap[id] = ev;
    }

    for (final reminder in storedReminders) {
      final incomingEvent = incomingEventMap[reminder.eventId];

      // If event was deleted or cancelled from schedule
      if (incomingEvent == null) {
        debugPrint(
            '⚠️ Event ${reminder.eventId} no longer exists. Removing reminder.');
        await removeReminder(eventId: reminder.eventId);
        continue;
      }

      final newStartTime = extractEventStartTime(incomingEvent);
      if (newStartTime == null) continue;

      // Check if event start time changed
      if (newStartTime.millisecondsSinceEpoch !=
          reminder.eventStartTime.millisecondsSinceEpoch) {
        debugPrint(
            '🔄 Event time changed for ${reminder.eventId} from ${reminder.eventStartTime} to $newStartTime. Rescheduling...');

        final newReminderTime = newStartTime.subtract(
          Duration(minutes: reminder.offsetMinutes),
        );

        if (newReminderTime.isAfter(DateTime.now())) {
          // Reschedule with updated time
          await createReminder(
            event: incomingEvent,
            offsetMinutes: reminder.offsetMinutes,
            explicitStartTime: newStartTime,
          );
        } else {
          // New time is already past, remove old reminder
          await removeReminder(eventId: reminder.eventId);
        }
      }
    }
  }
}
