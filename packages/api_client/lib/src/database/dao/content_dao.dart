import '../models/models.dart';
import '../../models/models.dart';
import 'base_dao.dart';

/// {@template content_dao}
/// Data Access Object for Content entities with caching support.
/// {@endtemplate}
class ContentDao extends BaseDao<CachedContent> {
  /// {@macro content_dao}
  ContentDao() : super('content');

  @override
  CachedContent fromDatabaseMap(Map<String, dynamic> map) {
    return CachedContent(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      filePath: map['file_path'] as String?,
      fileSize: map['file_size'] as int?,
      mimeType: map['mime_type'] as String?,
      description: map['description'] as String?,
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
      isDirty: (map['dirty'] as int?) == 1,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(CachedContent entity) {
    return <String, dynamic>{
      'id': entity.id,
      'name': entity.name,
      'type': entity.type,
      'file_path': entity.filePath,
      'file_size': entity.fileSize,
      'mime_type': entity.mimeType,
      'description': entity.description,
      'tags': entity.tags?.join(','),
      'created_at': entity.createdAt?.toIso8601String(),
      'updated_at': entity.updatedAt?.toIso8601String(),
      'synced_at': entity.syncedAt?.toIso8601String(),
      'dirty': entity.isDirty ? 1 : 0,
    };
  }

  /// Gets content by type
  Future<List<CachedContent>> getByType(String type) async {
    return getWhere(
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
  }

  /// Searches content by name or tags
  Future<List<CachedContent>> search(String query) async {
    final searchQuery = '%$query%';
    return getWhere(
      where: 'name LIKE ? OR description LIKE ? OR tags LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'created_at DESC',
    );
  }
}

/// {@template cached_content}
/// Content entity with local caching support.
/// {@endtemplate}
class CachedContent extends CachedEntity {
  /// {@macro cached_content}
  const CachedContent({
    required super.id,
    required this.name,
    required this.type,
    this.filePath,
    this.fileSize,
    this.mimeType,
    this.description,
    this.tags,
    this.createdAt,
    this.updatedAt,
    super.syncedAt,
    super.isDirty,
  });

  final String name;
  final String type;
  final String? filePath;
  final int? fileSize;
  final String? mimeType;
  final String? description;
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts to API Content model
  Content toContent() {
    return Content(
      id: id,
      name: name,
      type: type,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      description: description,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates from API Content model
  factory CachedContent.fromContent(Content content, {bool isDirty = false}) {
    return CachedContent(
      id: content.id,
      name: content.name,
      type: content.type,
      filePath: content.filePath,
      fileSize: content.fileSize,
      mimeType: content.mimeType,
      description: content.description,
      tags: content.tags,
      createdAt: content.createdAt,
      updatedAt: content.updatedAt,
      isDirty: isDirty,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'description': description,
      'tags': tags?.join(','),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'dirty': isDirty ? 1 : 0,
    };
  }

  @override
  CachedContent copyWithSync({
    DateTime? syncedAt,
    bool? isDirty,
  }) {
    return CachedContent(
      id: id,
      name: name,
      type: type,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      description: description,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String toString() {
    return 'CachedContent(id: $id, name: $name, type: $type, isDirty: $isDirty)';
  }
}