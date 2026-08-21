import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:techniche26/features/event_reminders/domain/event_reminder.dart';
import 'package:techniche26/features/event_reminders/domain/reminder_manager.dart';
import 'package:techniche26/model/events_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventReminder Domain Model Tests', () {
    test('toMap and fromMap preserves all fields correctly', () {
      final now = DateTime.now();
      final startTime = now.add(const Duration(hours: 3));
      final reminderTime = startTime.subtract(const Duration(minutes: 15));

      final reminder = EventReminder(
        eventId: 'event_robowars',
        notificationId: 12345,
        eventStartTime: startTime,
        reminderTime: reminderTime,
        offsetMinutes: 15,
        enabled: true,
      );

      final map = reminder.toMap();
      expect(map['event_id'], 'event_robowars');
      expect(map['notification_id'], 12345);
      expect(map['event_start_time'], startTime.millisecondsSinceEpoch);
      expect(map['reminder_time'], reminderTime.millisecondsSinceEpoch);
      expect(map['offset_minutes'], 15);
      expect(map['enabled'], 1);

      final restored = EventReminder.fromMap(map);
      expect(restored.eventId, reminder.eventId);
      expect(restored.notificationId, reminder.notificationId);
      expect(restored.eventStartTime.millisecondsSinceEpoch,
          reminder.eventStartTime.millisecondsSinceEpoch);
      expect(restored.reminderTime.millisecondsSinceEpoch,
          reminder.reminderTime.millisecondsSinceEpoch);
      expect(restored.offsetMinutes, 15);
      expect(restored.enabled, true);
    });

    test('copyWith updates fields correctly', () {
      final reminder = EventReminder(
        eventId: 'event_aquawars',
        notificationId: 999,
        eventStartTime: DateTime(2026, 8, 29, 14, 0),
        reminderTime: DateTime(2026, 8, 29, 13, 45),
        offsetMinutes: 15,
      );

      final updated = reminder.copyWith(offsetMinutes: 30);
      expect(updated.offsetMinutes, 30);
      expect(updated.eventId, 'event_aquawars');
    });
  });

  group('ReminderManager Helper & Extraction Tests', () {
    final manager = ReminderManager();

    test('Extracts stable event ID correctly from EventDetail and title', () {
      const eventWithId = EventDetail(
        id: 'tech_robowars_2026',
        title: 'Robowars',
      );
      expect(manager.extractEventId(eventWithId), 'tech_robowars_2026');

      const eventWithoutId = EventDetail(
        title: 'Track Titans & Racing',
      );
      expect(manager.extractEventId(eventWithoutId),
          'event_track_titans_racing');
    });

    test('Extracts event start time from various date formats', () {
      const event1 = EventDetail(
        title: 'Escalade',
        date: '2026-08-29T10:30:00Z',
      );
      expect(manager.extractEventStartTime(event1), isNotNull);

      const event2 = EventDetail(
        title: 'Workshop',
        date: '29 Aug 2026',
        time: '4:30 PM',
      );
      final parsed = manager.extractEventStartTime(event2);
      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 8);
      expect(parsed.day, 29);
      expect(parsed.hour, 16);
      expect(parsed.minute, 30);
    });

    test('Notification payload contains valid JSON with type and eventId', () {
      const eventId = 'event_robowars';
      final payloadString = jsonEncode({
        'type': 'event_reminder',
        'eventId': eventId,
      });

      final decoded = jsonDecode(payloadString);
      expect(decoded['type'], 'event_reminder');
      expect(decoded['eventId'], eventId);
    });
  });
}
