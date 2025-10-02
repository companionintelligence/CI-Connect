import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// {@template database_provider}
/// Provides SQLite database instance and handles schema migrations.
/// {@endtemplate}
class DatabaseProvider {
  /// {@macro database_provider}
  DatabaseProvider._();

  static final DatabaseProvider _instance = DatabaseProvider._();
  
  /// Singleton instance of DatabaseProvider
  static DatabaseProvider get instance => _instance;

  Database? _database;

  /// Current database version
  static const int _databaseVersion = 1;
  
  /// Database name
  static const String _databaseName = 'ci_connect.db';

  /// Gets the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates database tables on first run
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  /// Handles database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here when database version increases
    if (oldVersion < newVersion) {
      // Migration logic will go here
    }
  }

  /// Creates all database tables
  Future<void> _createTables(Database db) async {
    // People table
    await db.execute('''
      CREATE TABLE people (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Places table
    await db.execute('''
      CREATE TABLE places (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT,
        latitude REAL,
        longitude REAL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Content table for files and media
    await db.execute('''
      CREATE TABLE content (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        file_path TEXT,
        file_size INTEGER,
        mime_type TEXT,
        description TEXT,
        tags TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        company TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Things table
    await db.execute('''
      CREATE TABLE things (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        properties TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Calendar events table
    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        calendar_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        location TEXT,
        start_date_time TEXT NOT NULL,
        end_date_time TEXT NOT NULL,
        is_all_day INTEGER DEFAULT 0,
        attendees TEXT,
        recurrence_rule TEXT,
        status TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Calendars table
    await db.execute('''
      CREATE TABLE calendars (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT,
        time_zone TEXT,
        is_primary INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT,
        dirty INTEGER DEFAULT 0
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT,
        type TEXT,
        data TEXT,
        read INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // File sync tracking table
    await db.execute('''
      CREATE TABLE file_sync_records (
        id TEXT PRIMARY KEY,
        file_path TEXT NOT NULL UNIQUE,
        file_name TEXT NOT NULL,
        file_size INTEGER,
        file_type TEXT,
        mime_type TEXT,
        checksum TEXT,
        last_modified TEXT,
        synced_at TEXT,
        sync_status TEXT DEFAULT 'pending',
        error_message TEXT
      )
    ''');

    // API cache table for general caching
    await db.execute('''
      CREATE TABLE api_cache (
        key TEXT PRIMARY KEY,
        endpoint TEXT NOT NULL,
        data TEXT NOT NULL,
        expires_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await _createIndexes(db);
  }

  /// Creates database indexes
  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_people_email ON people (email)');
    await db.execute('CREATE INDEX idx_people_dirty ON people (dirty)');
    await db.execute('CREATE INDEX idx_places_name ON places (name)');
    await db.execute('CREATE INDEX idx_places_dirty ON places (dirty)');
    await db.execute('CREATE INDEX idx_content_type ON content (type)');
    await db.execute('CREATE INDEX idx_content_dirty ON content (dirty)');
    await db.execute('CREATE INDEX idx_contacts_email ON contacts (email)');
    await db.execute('CREATE INDEX idx_contacts_dirty ON contacts (dirty)');
    await db.execute('CREATE INDEX idx_things_category ON things (category)');
    await db.execute('CREATE INDEX idx_things_dirty ON things (dirty)');
    await db.execute('CREATE INDEX idx_calendar_events_calendar ON calendar_events (calendar_id)');
    await db.execute('CREATE INDEX idx_calendar_events_start ON calendar_events (start_date_time)');
    await db.execute('CREATE INDEX idx_calendar_events_dirty ON calendar_events (dirty)');
    await db.execute('CREATE INDEX idx_calendars_dirty ON calendars (dirty)');
    await db.execute('CREATE INDEX idx_notifications_type ON notifications (type)');
    await db.execute('CREATE INDEX idx_notifications_read ON notifications (read)');
    await db.execute('CREATE INDEX idx_file_sync_status ON file_sync_records (sync_status)');
    await db.execute('CREATE INDEX idx_file_sync_path ON file_sync_records (file_path)');
    await db.execute('CREATE INDEX idx_api_cache_endpoint ON api_cache (endpoint)');
    await db.execute('CREATE INDEX idx_api_cache_expires ON api_cache (expires_at)');
  }

  /// Closes the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('api_cache');
  }

  /// Clear all local data (for logout/reset)
  Future<void> clearAllData() async {
    final db = await database;
    
    final tables = [
      'people', 'places', 'content', 'contacts', 'things',
      'calendar_events', 'calendars', 'notifications',
      'file_sync_records', 'api_cache'
    ];
    
    for (final table in tables) {
      await db.delete(table);
    }
  }
}