import 'base_dao.dart';

// Placeholder DAO files - these can be expanded based on specific requirements

/// Place DAO placeholder
class PlacesDao extends BaseDao<Map<String, dynamic>> {
  PlacesDao() : super('places');

  @override
  Map<String, dynamic> fromDatabaseMap(Map<String, dynamic> map) => map;

  @override
  Map<String, dynamic> toDatabaseMap(Map<String, dynamic> entity) => entity;
}