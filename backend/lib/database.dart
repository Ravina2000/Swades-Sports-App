import 'package:sqlite3/sqlite3.dart';

import 'seed.dart';

class AppDatabase {
  AppDatabase({String? path}) {
    final dbPath = path ?? _defaultPath();
    _db = sqlite3.open(dbPath);
    _configure();
    _migrate();
    seedIfEmpty(_db);
  }

  late final Database _db;

  Database get db => _db;

  static String _defaultPath() {
    const envPath = String.fromEnvironment('DB_PATH');
    if (envPath.isNotEmpty) return envPath;
    return 'quickslot.db';
  }

  void _configure() {
    _db.execute('PRAGMA journal_mode = WAL;');
    _db.execute('PRAGMA foreign_keys = ON;');
  }

  void _migrate() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS venues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT ''
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        venue_id INTEGER NOT NULL,
        slot_date TEXT NOT NULL,
        start_hour INTEGER NOT NULL,
        end_hour INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'confirmed',
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (venue_id) REFERENCES venues(id)
      );
    ''');

    _db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_active_slot
      ON bookings (venue_id, slot_date, start_hour)
      WHERE status = 'confirmed';
    ''');
  }

  void close() => _db.dispose();
}

bool isSqliteUniqueViolation(Object error) {
  if (error is SqliteException && error.extendedResultCode == 2067) {
    return true;
  }
  final message = error.toString();
  return message.contains('UNIQUE constraint failed') ||
      message.contains('2067');
}
