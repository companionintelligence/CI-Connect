import 'dart:convert';

import 'package:api_client/src/database/dao/base_dao.dart';
import 'package:api_client/src/database/models/models.dart';

/// {@template api_cache_dao}
/// Data Access Object for API cache entries.
/// {@endtemplate}
class ApiCacheDao extends BaseDao<ApiCacheEntry> {
  /// {@macro api_cache_dao}
  ApiCacheDao() : super('api_cache');

  @override
  ApiCacheEntry fromDatabaseMap(Map<String, dynamic> map) {
    return ApiCacheEntry.fromDatabaseMap(map);
  }

  @override
  Map<String, dynamic> toDatabaseMap(ApiCacheEntry entity) {
    return entity.toDatabaseMap();
  }

  /// Stores API response in cache
  Future<void> cacheResponse(
    String endpoint,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    ttl ??= const Duration(hours: 1);
    
    final key = _generateCacheKey(endpoint);
    final entry = ApiCacheEntry(
      key: key,
      endpoint: endpoint,
      data: jsonEncode(data),
      expiresAt: DateTime.now().add(ttl),
      createdAt: DateTime.now(),
    );

    await insert(entry);
  }

  /// Gets cached response for endpoint
  Future<Map<String, dynamic>?> getCachedResponse(String endpoint) async {
    final key = _generateCacheKey(endpoint);
    final entry = await getById(key);
    
    if (entry == null || entry.isExpired) {
      if (entry != null) {
        await delete(key); // Clean up expired entry
      }
      return null;
    }

    try {
      return jsonDecode(entry.data) as Map<String, dynamic>;
    } catch (e) {
      // Invalid JSON, remove entry
      await delete(key);
      return null;
    }
  }

  /// Checks if endpoint has valid cached data
  Future<bool> hasCachedData(String endpoint) async {
    final key = _generateCacheKey(endpoint);
    final entry = await getById(key);
    return entry != null && entry.isValid;
  }

  /// Gets cache entries by endpoint pattern
  Future<List<ApiCacheEntry>> getByEndpointPattern(String pattern) async {
    return getWhere(
      where: 'endpoint LIKE ?',
      whereArgs: ['%$pattern%'],
      orderBy: 'created_at DESC',
    );
  }

  /// Removes expired cache entries
  Future<int> removeExpiredEntries() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    return db.delete(
      tableName,
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }

  /// Clears cache for specific endpoint pattern
  Future<int> clearCacheForEndpoint(String endpointPattern) async {
    final db = await database;
    return db.delete(
      tableName,
      where: 'endpoint LIKE ?',
      whereArgs: ['%$endpointPattern%'],
    );
  }

  /// Gets cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final db = await database;
    
    // Total entries
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    final total = totalResult.first['count']! as int;
    
    // Valid entries (not expired)
    final now = DateTime.now().toIso8601String();
    final validResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE expires_at > ?',
      [now],
    );
    final valid = validResult.first['count']! as int;
    
    // Cache size (approximate)
    final sizeResult = await db.rawQuery('SELECT SUM(LENGTH(data)) as size FROM $tableName');
    final size = sizeResult.first['size'] as int? ?? 0;
    
    // Most cached endpoints
    final endpointsResult = await db.rawQuery('''
      SELECT endpoint, COUNT(*) as count 
      FROM $tableName 
      GROUP BY endpoint 
      ORDER BY count DESC 
      LIMIT 10
    ''');
    
    return {
      'total_entries': total,
      'valid_entries': valid,
      'expired_entries': total - valid,
      'cache_size_bytes': size,
      'top_endpoints': endpointsResult,
      'hit_rate': total > 0 ? ((valid * 100) / total).round() : 0,
    };
  }

  /// Optimizes cache by removing old entries
  Future<void> optimizeCache({
    int? maxEntries,
    Duration? maxAge,
  }) async {
    maxEntries ??= 1000;
    maxAge ??= const Duration(days: 7);
    
    final db = await database;
    
    // Remove expired entries
    await removeExpiredEntries();
    
    // Remove old entries if we have too many
    final count = await this.count();
    if (count > maxEntries) {
      final excess = count - maxEntries;
      await db.rawQuery('''
        DELETE FROM $tableName 
        WHERE key IN (
          SELECT key FROM $tableName 
          ORDER BY created_at ASC 
          LIMIT $excess
        )
      ''');
    }
    
    // Remove entries older than maxAge
    final cutoffDate = DateTime.now().subtract(maxAge);
    await db.delete(
      tableName,
      where: 'created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Generates a cache key for an endpoint
  String _generateCacheKey(String endpoint) {
    // Simple hash-like key generation
    // In a production app, you might want to use a proper hash function
    return endpoint.replaceAll(RegExp('[^a-zA-Z0-9]'), '_').toLowerCase();
  }

  /// Warms up cache with frequently used endpoints
  Future<void> warmupCache(List<String> endpoints) async {
    // This would typically be called during app startup
    // to pre-fetch critical data
    for (final endpoint in endpoints) {
      if (!await hasCachedData(endpoint)) {
        // Mark for background fetch
        // Implementation would depend on specific API client
      }
    }
  }
}