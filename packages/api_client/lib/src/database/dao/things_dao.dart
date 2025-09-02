import 'base_dao.dart';

// Placeholder DAO files - these can be expanded based on specific requirements

/// Things DAO placeholder
class ThingsDao extends BaseDao<Map<String, dynamic>> {
  ThingsDao() : super('things');

  @override
  Map<String, dynamic> fromDatabaseMap(Map<String, dynamic> map) => map;

  @override
  Map<String, dynamic> toDatabaseMap(Map<String, dynamic> entity) => entity;
}