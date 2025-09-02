import 'package:sqflite/sqflite.dart';
import '../database_provider.dart';

/// {@template base_dao}
/// Base Data Access Object with common CRUD operations.
/// {@endtemplate}
abstract class BaseDao<T> {
  /// {@macro base_dao}
  BaseDao(this.tableName);

  /// Name of the database table
  final String tableName;

  /// Gets the database instance
  Future<Database> get database => DatabaseProvider.instance.database;

  /// Converts a database map to an entity
  T fromDatabaseMap(Map<String, dynamic> map);

  /// Converts an entity to a database map
  Map<String, dynamic> toDatabaseMap(T entity);

  /// Inserts an entity into the database
  Future<String> insert(T entity) async {
    final db = await database;
    final map = toDatabaseMap(entity);
    await db.insert(tableName, map, conflictAlgorithm: ConflictAlgorithm.replace);
    return map['id'] as String;
  }

  /// Inserts multiple entities in a batch
  Future<void> insertBatch(List<T> entities) async {
    if (entities.isEmpty) return;
    
    final db = await database;
    final batch = db.batch();
    
    for (final entity in entities) {
      final map = toDatabaseMap(entity);
      batch.insert(tableName, map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }

  /// Gets an entity by ID
  Future<T?> getById(String id) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return fromDatabaseMap(result.first);
  }

  /// Gets all entities
  Future<List<T>> getAll({
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final result = await db.query(
      tableName,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    
    return result.map(fromDatabaseMap).toList();
  }

  /// Updates an entity
  Future<int> update(T entity) async {
    final db = await database;
    final map = toDatabaseMap(entity);
    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [map['id']],
    );
  }

  /// Deletes an entity by ID
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all entities
  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(tableName);
  }

  /// Counts all entities
  Future<int> count() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Gets entities with custom where clause
  Future<List<T>> getWhere({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    
    return result.map(fromDatabaseMap).toList();
  }

  /// Gets entities that need to be synced (dirty = 1)
  Future<List<T>> getDirtyEntities() async {
    return getWhere(where: 'dirty = ?', whereArgs: [1]);
  }

  /// Marks an entity as dirty (needs sync)
  Future<void> markDirty(String id) async {
    final db = await database;
    await db.update(
      tableName,
      {'dirty': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks an entity as clean (synced)
  Future<void> markClean(String id) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'dirty': 0,
        'synced_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}