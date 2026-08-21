import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReminderDatabase {
  static final ReminderDatabase _instance = ReminderDatabase._internal();
  factory ReminderDatabase() => _instance;
  ReminderDatabase._internal();

  static Database? _database;

  static const String tableName = 'event_reminders';
  static const String columnEventId = 'event_id';
  static const String columnNotificationId = 'notification_id';
  static const String columnEventStartTime = 'event_start_time';
  static const String columnReminderTime = 'reminder_time';
  static const String columnOffsetMinutes = 'offset_minutes';
  static const String columnEnabled = 'enabled';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'techniche_reminders.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnEventId TEXT PRIMARY KEY,
        $columnNotificationId INTEGER NOT NULL,
        $columnEventStartTime INTEGER NOT NULL,
        $columnReminderTime INTEGER NOT NULL,
        $columnOffsetMinutes INTEGER NOT NULL,
        $columnEnabled INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
