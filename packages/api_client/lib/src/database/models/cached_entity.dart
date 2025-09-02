/// {@template cached_entity}
/// Base class for entities that can be cached locally with sync tracking.
/// {@endtemplate}
abstract class CachedEntity {
  /// {@macro cached_entity}
  const CachedEntity({
    required this.id,
    this.syncedAt,
    this.isDirty = false,
  });

  /// Unique identifier
  final String id;

  /// When this entity was last synced with the server
  final DateTime? syncedAt;

  /// Whether this entity has local changes that need to be synced
  final bool isDirty;

  /// Converts to a map for database storage
  Map<String, dynamic> toDatabaseMap();

  /// Creates an instance from a database map
  static T fromDatabaseMap<T extends CachedEntity>(Map<String, dynamic> map) {
    throw UnimplementedError('Subclasses must implement fromDatabaseMap');
  }

  /// Creates a copy with updated sync information
  CachedEntity copyWithSync({
    DateTime? syncedAt,
    bool? isDirty,
  });
}