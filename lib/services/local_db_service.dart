import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:latlong2/latlong.dart';

class LocalDbService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'live_run_route.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lat REAL,
            lng REAL
          )
        ''');
      },
    );
  }

  /// Clears the local database. Called at the start and end of a run.
  Future<void> clearRoutePoints() async {
    final db = await database;
    await db.delete('route_points');
  }

  /// Inserts a batch of new GPS points into SQLite to persist them locally.
  Future<void> insertRoutePoints(List<LatLng> points) async {
    if (points.isEmpty) return;
    final db = await database;
    
    // Use batch insertion for performance
    Batch batch = db.batch();
    for (var p in points) {
      batch.insert('route_points', {'lat': p.latitude, 'lng': p.longitude});
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves the entire recorded route to be saved to Supabase at the end of the run.
  Future<List<LatLng>> getRoutePoints() async {
    final db = await database;
    final maps = await db.query('route_points', orderBy: 'id ASC');
    
    return maps.map((map) {
      return LatLng(map['lat'] as double, map['lng'] as double);
    }).toList();
  }
}
