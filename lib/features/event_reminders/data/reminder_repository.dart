import 'package:sqflite/sqflite.dart';
import '../domain/event_reminder.dart';
import 'reminder_database.dart';

class ReminderRepository {
  final ReminderDatabase _dbProvider;

  ReminderRepository({ReminderDatabase? dbProvider})
      : _dbProvider = dbProvider ?? ReminderDatabase();

  Future<void> insertOrUpdate(EventReminder reminder) async {
    final db = await _dbProvider.database;
    await db.insert(
      ReminderDatabase.tableName,
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<EventReminder?> getReminder(String eventId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      ReminderDatabase.tableName,
      where: '${ReminderDatabase.columnEventId} = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return EventReminder.fromMap(maps.first);
    }
    return null;
  }

  Future<List<EventReminder>> getAllReminders() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      ReminderDatabase.tableName,
      orderBy: '${ReminderDatabase.columnReminderTime} ASC',
    );

    return maps.map((map) => EventReminder.fromMap(map)).toList();
  }

  Future<int> deleteReminder(String eventId) async {
    final db = await _dbProvider.database;
    return await db.delete(
      ReminderDatabase.tableName,
      where: '${ReminderDatabase.columnEventId} = ?',
      whereArgs: [eventId],
    );
  }

  Future<int> deleteAll() async {
    final db = await _dbProvider.database;
    return await db.delete(ReminderDatabase.tableName);
  }

  Future<int> deleteExpiredReminders(DateTime currentTime) async {
    final db = await _dbProvider.database;
    return await db.delete(
      ReminderDatabase.tableName,
      where: '${ReminderDatabase.columnEventStartTime} < ?',
      whereArgs: [currentTime.millisecondsSinceEpoch],
    );
  }
}
