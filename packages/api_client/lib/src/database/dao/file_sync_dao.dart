import '../models/models.dart';
import 'base_dao.dart';

/// {@template file_sync_dao}
/// Data Access Object for FileSyncRecord entities.
/// {@endtemplate}
class FileSyncDao extends BaseDao<FileSyncRecord> {
  /// {@macro file_sync_dao}
  FileSyncDao() : super('file_sync_records');

  @override
  FileSyncRecord fromDatabaseMap(Map<String, dynamic> map) {
    return FileSyncRecord.fromDatabaseMap(map);
  }

  @override
  Map<String, dynamic> toDatabaseMap(FileSyncRecord entity) {
    return entity.toDatabaseMap();
  }

  /// Gets files by sync status
  Future<List<FileSyncRecord>> getByStatus(FileSyncStatus status) async {
    return getWhere(
      where: 'sync_status = ?',
      whereArgs: [status.name],
      orderBy: 'last_modified DESC',
    );
  }

  /// Gets files that need to be synced
  Future<List<FileSyncRecord>> getFilesToSync() async {
    return getWhere(
      where: 'sync_status IN (?, ?)',
      whereArgs: [FileSyncStatus.pending.name, FileSyncStatus.failed.name],
      orderBy: 'last_modified ASC',
    );
  }

  /// Gets files by type
  Future<List<FileSyncRecord>> getByFileType(String fileType) async {
    return getWhere(
      where: 'file_type = ?',
      whereArgs: [fileType],
      orderBy: 'file_name ASC',
    );
  }

  /// Gets files by path pattern
  Future<List<FileSyncRecord>> getByPathPattern(String pattern) async {
    return getWhere(
      where: 'file_path LIKE ?',
      whereArgs: ['%$pattern%'],
      orderBy: 'file_path ASC',
    );
  }

  /// Gets file by exact path
  Future<FileSyncRecord?> getByPath(String filePath) async {
    final results = await getWhere(
      where: 'file_path = ?',
      whereArgs: [filePath],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Updates sync status for a file
  Future<void> updateSyncStatus(
    String id,
    FileSyncStatus status, {
    String? errorMessage,
  }) async {
    final db = await database;
    final updateMap = <String, dynamic>{
      'sync_status': status.name,
    };

    if (status == FileSyncStatus.synced) {
      updateMap['synced_at'] = DateTime.now().toIso8601String();
      updateMap['error_message'] = null;
    } else if (status == FileSyncStatus.failed && errorMessage != null) {
      updateMap['error_message'] = errorMessage;
    } else if (status == FileSyncStatus.syncing) {
      updateMap['error_message'] = null;
    }

    await db.update(
      tableName,
      updateMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets sync statistics
  Future<Map<String, int>> getSyncStats() async {
    final db = await database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    final total = totalResult.first['count'] as int;
    
    final syncedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE sync_status = ?',
      [FileSyncStatus.synced.name],
    );
    final synced = syncedResult.first['count'] as int;
    
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE sync_status = ?',
      [FileSyncStatus.pending.name],
    );
    final pending = pendingResult.first['count'] as int;
    
    final failedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE sync_status = ?',
      [FileSyncStatus.failed.name],
    );
    final failed = failedResult.first['count'] as int;

    return {
      'total': total,
      'synced': synced,
      'pending': pending,
      'failed': failed,
      'success_rate': total > 0 ? ((synced * 100) / total).round() : 0,
    };
  }

  /// Removes old sync records (cleanup)
  Future<int> removeOldRecords({Duration? olderThan}) async {
    olderThan ??= const Duration(days: 30);
    final cutoffDate = DateTime.now().subtract(olderThan);
    
    final db = await database;
    return await db.delete(
      tableName,
      where: 'synced_at < ? AND sync_status = ?',
      whereArgs: [cutoffDate.toIso8601String(), FileSyncStatus.synced.name],
    );
  }

  /// Resets failed syncs for retry
  Future<int> resetFailedSyncs() async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'sync_status': FileSyncStatus.pending.name,
        'error_message': null,
      },
      where: 'sync_status = ?',
      whereArgs: [FileSyncStatus.failed.name],
    );
  }
}