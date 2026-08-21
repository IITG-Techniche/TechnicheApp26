class EventReminder {
  final String eventId;
  final int notificationId;
  final DateTime eventStartTime;
  final DateTime reminderTime;
  final int offsetMinutes;
  final bool enabled;

  const EventReminder({
    required this.eventId,
    required this.notificationId,
    required this.eventStartTime,
    required this.reminderTime,
    required this.offsetMinutes,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'notification_id': notificationId,
      'event_start_time': eventStartTime.millisecondsSinceEpoch,
      'reminder_time': reminderTime.millisecondsSinceEpoch,
      'offset_minutes': offsetMinutes,
      'enabled': enabled ? 1 : 0,
    };
  }

  factory EventReminder.fromMap(Map<String, dynamic> map) {
    return EventReminder(
      eventId: map['event_id'] as String,
      notificationId: map['notification_id'] as int,
      eventStartTime:
          DateTime.fromMillisecondsSinceEpoch(map['event_start_time'] as int),
      reminderTime:
          DateTime.fromMillisecondsSinceEpoch(map['reminder_time'] as int),
      offsetMinutes: map['offset_minutes'] as int,
      enabled: (map['enabled'] as int? ?? 1) == 1,
    );
  }

  EventReminder copyWith({
    String? eventId,
    int? notificationId,
    DateTime? eventStartTime,
    DateTime? reminderTime,
    int? offsetMinutes,
    bool? enabled,
  }) {
    return EventReminder(
      eventId: eventId ?? this.eventId,
      notificationId: notificationId ?? this.notificationId,
      eventStartTime: eventStartTime ?? this.eventStartTime,
      reminderTime: reminderTime ?? this.reminderTime,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      enabled: enabled ?? this.enabled,
    );
  }
}
