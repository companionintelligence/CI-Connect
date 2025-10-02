/// {@template data_sync_service}
/// Service for synchronizing local SQLite data with CI-Server API.
/// Handles difference mapping, conflict resolution, and batch sync operations.
/// {@endtemplate}
library;
import 'package:api_client/src/database/database_provider.dart';
import 'package:dio/dio.dart';

/// {@template sync_result}
/// Result of a synchronization operation.
/// {@endtemplate}
class SyncResult {
  /// {@macro sync_result}
  const SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.conflictCount,
    this.errors = const [],
    this.conflicts = const [],
  });

  /// Whether the sync operation was successful
  final bool success;

  /// Number of records successfully synced
  final int syncedCount;

  /// Number of records that failed to sync
  final int failedCount;

  /// Number of conflicts detected
  final int conflictCount;

  /// List of errors encountered during sync
  final List<String> errors;

  /// List of conflicts that need manual resolution
  final List<SyncConflict> conflicts;
}

/// {@template sync_conflict}
/// Represents a conflict between local and server data.
/// {@endtemplate}
class SyncConflict {
  /// {@macro sync_conflict}
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    required this.conflictType,
  });

  /// Type of entity in conflict (e.g., 'person', 'contact', 'content')
  final String entityType;

  /// ID of the conflicting entity
  final String entityId;

  /// Local version of the data
  final Map<String, dynamic> localData;

  /// Server version of the data
  final Map<String, dynamic> serverData;

  /// Type of conflict (e.g., 'modified_both', 'deleted_local', 'deleted_server')
  final String conflictType;
}

/// {@template difference_map}
/// Map of differences between local and server data.
/// {@endtemplate}
class DifferenceMap {
  /// {@macro difference_map}
  const DifferenceMap({
    required this.toCreate,
    required this.toUpdate,
    required this.toDelete,
    required this.conflicts,
  });

  /// Records to create on server
  final List<Map<String, dynamic>> toCreate;

  /// Records to update on server
  final List<Map<String, dynamic>> toUpdate;

  /// Records to delete on server
  final List<String> toDelete;

  /// Records with conflicts
  final List<SyncConflict> conflicts;
}

/// {@template data_sync_service}
/// Service for synchronizing local SQLite data with CI-Server API.
/// {@endtemplate}
class DataSyncService {
  /// {@macro data_sync_service}
  DataSyncService({
    required this.apiClient,
    required this.databaseProvider,
  });

  final Dio apiClient;
  final DatabaseProvider databaseProvider;

  /// Synchronizes all dirty records with the server.
  Future<SyncResult> syncAllDirtyRecords() async {
    final results = <SyncResult>[];
    final allErrors = <String>[];
    final allConflicts = <SyncConflict>[];

    // Sync each entity type
    final entityTypes = [
      'people',
      'places',
      'content',
      'contacts',
      'things',
      'calendar_events',
      'calendars',
    ];

    for (final entityType in entityTypes) {
      try {
        final result = await syncEntityType(entityType);
        results.add(result);
        allErrors.addAll(result.errors);
        allConflicts.addAll(result.conflicts);
      } catch (e) {
        allErrors.add('Failed to sync $entityType: $e');
      }
    }

    final totalSynced = results.fold(
      0,
      (sum, result) => sum + result.syncedCount,
    );
    final totalFailed = results.fold(
      0,
      (sum, result) => sum + result.failedCount,
    );
    final totalConflicts = results.fold(
      0,
      (sum, result) => sum + result.conflictCount,
    );

    return SyncResult(
      success: allErrors.isEmpty,
      syncedCount: totalSynced,
      failedCount: totalFailed,
      conflictCount: totalConflicts,
      errors: allErrors,
      conflicts: allConflicts,
    );
  }

  /// Synchronizes a specific entity type.
  Future<SyncResult> syncEntityType(String entityType) async {
    final db = await databaseProvider.database;

    // Get all dirty records for this entity type
    final dirtyRecords = await db.query(
      entityType,
      where: 'dirty = ?',
      whereArgs: [1],
    );

    if (dirtyRecords.isEmpty) {
      return const SyncResult(
        success: true,
        syncedCount: 0,
        failedCount: 0,
        conflictCount: 0,
      );
    }

    // Create difference map
    final differenceMap = await _createDifferenceMap(entityType, dirtyRecords);

    // Apply differences to server
    final result = await _applyDifferences(entityType, differenceMap);

    // Update local records based on sync result
    await _updateLocalRecords(entityType, result);

    return result;
  }

  /// Creates a difference map between local and server data.
  Future<DifferenceMap> _createDifferenceMap(
    String entityType,
    List<Map<String, dynamic>> localRecords,
  ) async {
    final toCreate = <Map<String, dynamic>>[];
    final toUpdate = <Map<String, dynamic>>[];
    final toDelete = <String>[];
    final conflicts = <SyncConflict>[];

    for (final localRecord in localRecords) {
      final id = localRecord['id'] as String;
      final syncedAt = localRecord['synced_at'] as String?;

      if (syncedAt == null) {
        // Never synced - create on server
        toCreate.add(localRecord);
      } else {
        // Check if record exists on server and compare timestamps
        try {
          final serverRecord = await _fetchServerRecord(entityType, id);

          if (serverRecord == null) {
            // Record was deleted on server
            if (localRecord['deleted'] == 1) {
              // Local deletion confirmed
              toDelete.add(id);
            } else {
              // Conflict: server deleted, local modified
              conflicts.add(
                SyncConflict(
                  entityType: entityType,
                  entityId: id,
                  localData: localRecord,
                  serverData: {},
                  conflictType: 'deleted_server',
                ),
              );
            }
          } else {
            // Compare timestamps
            final localUpdated = DateTime.parse(
              localRecord['updated_at'] as String,
            );
            final serverUpdated = DateTime.parse(
              serverRecord['updated_at'] as String,
            );

            if (localUpdated.isAfter(serverUpdated)) {
              // Local is newer - update server
              toUpdate.add(localRecord);
            } else if (localUpdated.isBefore(serverUpdated)) {
              // Server is newer - conflict
              conflicts.add(
                SyncConflict(
                  entityType: entityType,
                  entityId: id,
                  localData: localRecord,
                  serverData: serverRecord,
                  conflictType: 'modified_both',
                ),
              );
            }
            // If timestamps are equal, no action needed
          }
        } catch (e) {
          // Error fetching server record - treat as conflict
          conflicts.add(
            SyncConflict(
              entityType: entityType,
              entityId: id,
              localData: localRecord,
              serverData: {},
              conflictType: 'fetch_error',
            ),
          );
        }
      }
    }

    return DifferenceMap(
      toCreate: toCreate,
      toUpdate: toUpdate,
      toDelete: toDelete,
      conflicts: conflicts,
    );
  }

  /// Fetches a record from the server.
  Future<Map<String, dynamic>?> _fetchServerRecord(
    String entityType,
    String id,
  ) async {
    try {
      final response = await apiClient.get('/$entityType/$id');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Applies differences to the server.
  Future<SyncResult> _applyDifferences(
    String entityType,
    DifferenceMap differenceMap,
  ) async {
    var syncedCount = 0;
    var failedCount = 0;
    final errors = <String>[];

    // Create new records
    for (final record in differenceMap.toCreate) {
      try {
        final response = await apiClient.post('/$entityType', data: record);
        if (response.statusCode == 200 || response.statusCode == 201) {
          syncedCount++;
        } else {
          failedCount++;
          errors.add(
            'Failed to create ${record['id']}: ${response.statusCode}',
          );
        }
      } catch (e) {
        failedCount++;
        errors.add('Failed to create ${record['id']}: $e');
      }
    }

    // Update existing records
    for (final record in differenceMap.toUpdate) {
      try {
        final response = await apiClient.put(
          '/$entityType/${record['id']}',
          data: record,
        );
        if (response.statusCode == 200) {
          syncedCount++;
        } else {
          failedCount++;
          errors.add(
            'Failed to update ${record['id']}: ${response.statusCode}',
          );
        }
      } catch (e) {
        failedCount++;
        errors.add('Failed to update ${record['id']}: $e');
      }
    }

    // Delete records
    for (final id in differenceMap.toDelete) {
      try {
        final response = await apiClient.delete('/$entityType/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          syncedCount++;
        } else {
          failedCount++;
          errors.add('Failed to delete $id: ${response.statusCode}');
        }
      } catch (e) {
        failedCount++;
        errors.add('Failed to delete $id: $e');
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      syncedCount: syncedCount,
      failedCount: failedCount,
      conflictCount: differenceMap.conflicts.length,
      errors: errors,
      conflicts: differenceMap.conflicts,
    );
  }

  /// Updates local records based on sync results.
  Future<void> _updateLocalRecords(String entityType, SyncResult result) async {
    final db = await databaseProvider.database;

    // Mark successfully synced records as clean
    for (final conflict in result.conflicts) {
      if (conflict.entityType == entityType) {
        // For conflicts, we'll keep them dirty for manual resolution
        continue;
      }
    }

    // Update synced_at timestamp for successful syncs
    // This would be implemented based on the specific sync results
  }

  /// Resolves a sync conflict by choosing local or server version.
  Future<bool> resolveConflict(
    SyncConflict conflict,
    bool useLocalVersion,
  ) async {
    try {
      if (useLocalVersion) {
        // Use local version - update server
        final response = await apiClient.put(
          '/${conflict.entityType}/${conflict.entityId}',
          data: conflict.localData,
        );
        return response.statusCode == 200;
      } else {
        // Use server version - update local
        final db = await databaseProvider.database;
        await db.update(
          conflict.entityType,
          {
            ...conflict.serverData,
            'dirty': 0,
            'synced_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [conflict.entityId],
        );
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// Gets statistics about sync status.
  Future<Map<String, dynamic>> getSyncStats() async {
    final db = await databaseProvider.database;
    final stats = <String, dynamic>{};

    final entityTypes = [
      'people',
      'places',
      'content',
      'contacts',
      'things',
      'calendar_events',
      'calendars',
    ];

    for (final entityType in entityTypes) {
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $entityType',
      );
      final dirtyResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $entityType WHERE dirty = 1',
      );

      stats[entityType] = {
        'total': totalResult.first['count']! as int,
        'dirty': dirtyResult.first['count']! as int,
      };
    }

    return stats;
  }

  /// Forces a full sync by marking all records as dirty.
  Future<void> markAllAsDirty() async {
    final db = await databaseProvider.database;
    final entityTypes = [
      'people',
      'places',
      'content',
      'contacts',
      'things',
      'calendar_events',
      'calendars',
    ];

    for (final entityType in entityTypes) {
      await db.update(
        entityType,
        {'dirty': 1},
        where: 'dirty = 0',
      );
    }
  }

  /// Clears all dirty flags (use with caution).
  Future<void> clearAllDirtyFlags() async {
    final db = await databaseProvider.database;
    final entityTypes = [
      'people',
      'places',
      'content',
      'contacts',
      'things',
      'calendar_events',
      'calendars',
    ];

    for (final entityType in entityTypes) {
      await db.update(
        entityType,
        {'dirty': 0},
        where: 'dirty = 1',
      );
    }
  }
}
