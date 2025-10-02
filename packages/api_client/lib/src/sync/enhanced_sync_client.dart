/// {@template enhanced_sync_client}
/// Enhanced API client with integrated SQLite caching and sync capabilities.
/// Provides offline-first functionality with automatic synchronization.
/// {@endtemplate}
library;
import 'package:api_client/src/database/database_provider.dart';
import 'package:api_client/src/models/models.dart';
import 'package:api_client/src/sync/data_sync_service.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

/// {@template enhanced_sync_client}
/// Enhanced API client with integrated SQLite caching and sync capabilities.
/// {@endtemplate}
class EnhancedSyncClient {
  /// {@macro enhanced_sync_client}
  EnhancedSyncClient({
    required String baseUrl,
    Dio? dio,
    DatabaseProvider? databaseProvider,
  }) : _baseUrl = baseUrl,
       _dio = dio ?? Dio(),
       _databaseProvider = databaseProvider ?? DatabaseProvider.instance {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _syncService = DataSyncService(
      apiClient: _dio,
      databaseProvider: _databaseProvider,
    );
  }

  final String _baseUrl;
  final Dio _dio;
  final DatabaseProvider _databaseProvider;
  late final DataSyncService _syncService;

  /// Gets the sync service instance
  DataSyncService get syncService => _syncService;

  /// Initializes the client and database
  Future<void> initialize() async {
    await _databaseProvider.database;
  }

  // People endpoints with caching

  /// Get all people with automatic caching and sync
  Future<List<Person>> getPeople({
    bool forceRefresh = false,
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    final db = await _databaseProvider.database;

    if (!forceRefresh) {
      // Try to get from cache first
      final cachedPeople = await _getCachedPeople(filters);
      if (cachedPeople.isNotEmpty) {
        return cachedPeople;
      }
    }

    try {
      // Fetch from server
      final response = await _dio.get<List<dynamic>>(
        '/people',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );

      if (response.data != null) {
        final people = (response.data!)
            .map((json) => Person.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the results
        await _cachePeople(people);

        return people;
      }
      return [];
    } catch (e) {
      // Fallback to cached data on error
      return _getCachedPeople(filters);
    }
  }

  /// Get cached people from local database
  Future<List<Person>> _getCachedPeople(Map<String, dynamic>? filters) async {
    final db = await _databaseProvider.database;

    var whereClause = '';
    final whereArgs = <dynamic>[];

    if (filters != null && filters.isNotEmpty) {
      final conditions = <String>[];
      filters.forEach((key, value) {
        conditions.add('$key = ?');
        whereArgs.add(value);
      });
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final results = await db.rawQuery(
      'SELECT * FROM people $whereClause ORDER BY updated_at DESC',
      whereArgs,
    );

    return results.map(Person.fromJson).toList();
  }

  /// Cache people in local database
  Future<void> _cachePeople(List<Person> people) async {
    final db = await _databaseProvider.database;

    for (final person in people) {
      await db.insert(
        'people',
        {
          ...person.toJson(),
          'synced_at': DateTime.now().toIso8601String(),
          'dirty': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Create a new person with local caching
  Future<Person> createPerson(Person person) async {
    final db = await _databaseProvider.database;

    try {
      // Try to create on server first
      final response = await _dio.post<Map<String, dynamic>>(
        '/people',
        data: person.toJson(),
      );

      if (response.data != null) {
        final createdPerson = Person.fromJson(response.data!);

        // Cache the created person
        await db.insert(
          'people',
          {
            ...createdPerson.toJson(),
            'synced_at': DateTime.now().toIso8601String(),
            'dirty': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        return createdPerson;
      }
      throw Exception('Failed to create person on server');
    } catch (e) {
      // Create locally and mark as dirty for later sync
      final localPerson = person.copyWith(
        id: person.id.isEmpty ? _generateId() : person.id,
      );

      await db.insert(
        'people',
        {
          ...localPerson.toJson(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'dirty': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return localPerson;
    }
  }

  /// Update a person with local caching
  Future<Person> updatePerson(String id, Person person) async {
    final db = await _databaseProvider.database;

    try {
      // Try to update on server first
      final response = await _dio.put<Map<String, dynamic>>(
        '/people/$id',
        data: person.toJson(),
      );

      if (response.data != null) {
        final updatedPerson = Person.fromJson(response.data!);

        // Update local cache
        await db.update(
          'people',
          {
            ...updatedPerson.toJson(),
            'synced_at': DateTime.now().toIso8601String(),
            'dirty': 0,
          },
          where: 'id = ?',
          whereArgs: [id],
        );

        return updatedPerson;
      }
      throw Exception('Failed to update person on server');
    } catch (e) {
      // Update locally and mark as dirty for later sync
      await db.update(
        'people',
        {
          ...person.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
          'dirty': 1,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      return person;
    }
  }

  /// Delete a person with local caching
  Future<void> deletePerson(String id) async {
    final db = await _databaseProvider.database;

    try {
      // Try to delete on server first
      await _dio.delete('/people/$id');

      // Remove from local cache
      await db.delete('people', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // Mark as deleted locally for later sync
      await db.update(
        'people',
        {
          'deleted': 1,
          'updated_at': DateTime.now().toIso8601String(),
          'dirty': 1,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Places endpoints with caching

  /// Get all places with automatic caching and sync
  Future<List<Place>> getPlaces({
    bool forceRefresh = false,
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    final db = await _databaseProvider.database;

    if (!forceRefresh) {
      // Try to get from cache first
      final cachedPlaces = await _getCachedPlaces(filters);
      if (cachedPlaces.isNotEmpty) {
        return cachedPlaces;
      }
    }

    try {
      // Fetch from server
      final response = await _dio.get<List<dynamic>>(
        '/places',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );

      if (response.data != null) {
        final places = (response.data!)
            .map((json) => Place.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the results
        await _cachePlaces(places);

        return places;
      }
      return [];
    } catch (e) {
      // Fallback to cached data on error
      return _getCachedPlaces(filters);
    }
  }

  /// Get cached places from local database
  Future<List<Place>> _getCachedPlaces(Map<String, dynamic>? filters) async {
    final db = await _databaseProvider.database;

    var whereClause = '';
    final whereArgs = <dynamic>[];

    if (filters != null && filters.isNotEmpty) {
      final conditions = <String>[];
      filters.forEach((key, value) {
        conditions.add('$key = ?');
        whereArgs.add(value);
      });
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final results = await db.rawQuery(
      'SELECT * FROM places $whereClause ORDER BY updated_at DESC',
      whereArgs,
    );

    return results.map(Place.fromJson).toList();
  }

  /// Cache places in local database
  Future<void> _cachePlaces(List<Place> places) async {
    final db = await _databaseProvider.database;

    for (final place in places) {
      await db.insert(
        'places',
        {
          ...place.toJson(),
          'synced_at': DateTime.now().toIso8601String(),
          'dirty': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Content endpoints with caching

  /// Get all content with automatic caching and sync
  Future<List<Content>> getContent({
    bool forceRefresh = false,
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    final db = await _databaseProvider.database;

    if (!forceRefresh) {
      // Try to get from cache first
      final cachedContent = await _getCachedContent(filters);
      if (cachedContent.isNotEmpty) {
        return cachedContent;
      }
    }

    try {
      // Fetch from server
      final response = await _dio.get<List<dynamic>>(
        '/content',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );

      if (response.data != null) {
        final content = (response.data!)
            .map((json) => Content.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the results
        await _cacheContent(content);

        return content;
      }
      return [];
    } catch (e) {
      // Fallback to cached data on error
      return _getCachedContent(filters);
    }
  }

  /// Get cached content from local database
  Future<List<Content>> _getCachedContent(Map<String, dynamic>? filters) async {
    final db = await _databaseProvider.database;

    var whereClause = '';
    final whereArgs = <dynamic>[];

    if (filters != null && filters.isNotEmpty) {
      final conditions = <String>[];
      filters.forEach((key, value) {
        conditions.add('$key = ?');
        whereArgs.add(value);
      });
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }

    final results = await db.rawQuery(
      'SELECT * FROM content $whereClause ORDER BY updated_at DESC',
      whereArgs,
    );

    return results.map(Content.fromJson).toList();
  }

  /// Cache content in local database
  Future<void> _cacheContent(List<Content> content) async {
    final db = await _databaseProvider.database;

    for (final item in content) {
      await db.insert(
        'content',
        {
          ...item.toJson(),
          'synced_at': DateTime.now().toIso8601String(),
          'dirty': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Sync operations

  /// Performs a full sync of all dirty records
  Future<SyncResult> performFullSync() async {
    return _syncService.syncAllDirtyRecords();
  }

  /// Gets sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    return _syncService.getSyncStats();
  }

  /// Resolves a sync conflict
  Future<bool> resolveConflict(
    SyncConflict conflict,
    bool useLocalVersion,
  ) async {
    return _syncService.resolveConflict(conflict, useLocalVersion);
  }

  /// Marks all records as dirty for full resync
  Future<void> markAllAsDirty() async {
    await _syncService.markAllAsDirty();
  }

  /// Clears all dirty flags
  Future<void> clearAllDirtyFlags() async {
    await _syncService.clearAllDirtyFlags();
  }

  /// Generates a unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Closes the client and database connections
  Future<void> close() async {
    await _databaseProvider.close();
  }
}
