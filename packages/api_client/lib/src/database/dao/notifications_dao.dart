import 'package:api_client/src/database/dao/base_dao.dart';
import 'package:api_client/src/database/models/models.dart';

/// {@template notifications_dao}
/// Data Access Object for NotificationRecord entities.
/// {@endtemplate}
class NotificationsDao extends BaseDao<NotificationRecord> {
  /// {@macro notifications_dao}
  NotificationsDao() : super('notifications');

  @override
  NotificationRecord fromDatabaseMap(Map<String, dynamic> map) {
    return NotificationRecord.fromDatabaseMap(map);
  }

  @override
  Map<String, dynamic> toDatabaseMap(NotificationRecord entity) {
    return entity.toDatabaseMap();
  }

  /// Gets unread notifications
  Future<List<NotificationRecord>> getUnread() async {
    return getWhere(
      where: 'read = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  /// Gets notifications by type
  Future<List<NotificationRecord>> getByType(String type) async {
    return getWhere(
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
  }

  /// Marks notification as read
  Future<void> markAsRead(String id) async {
    final db = await database;
    await db.update(
      tableName,
      {'read': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks all notifications as read
  Future<void> markAllAsRead() async {
    final db = await database;
    await db.update(
      tableName,
      {'read': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'read = ?',
      whereArgs: [0],
    );
  }

  /// Gets unread count
  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableName WHERE read = ?',
      [0],
    );
    return result.first['COUNT(*)'] as int? ?? 0;
  }
}
