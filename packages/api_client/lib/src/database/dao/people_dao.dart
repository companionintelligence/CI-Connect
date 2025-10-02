import 'package:api_client/src/database/dao/base_dao.dart';
import 'package:api_client/src/models/models.dart';

/// {@template people_dao}
/// Data Access Object for Person entities with caching support.
/// {@endtemplate}
class PeopleDao extends BaseDao<CachedPerson> {
  /// {@macro people_dao}
  PeopleDao() : super('people');

  @override
  CachedPerson fromDatabaseMap(Map<String, dynamic> map) {
    return CachedPerson(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
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
  Map<String, dynamic> toDatabaseMap(CachedPerson entity) {
    return <String, dynamic>{
      'id': entity.id,
      'name': entity.name,
      'email': entity.email,
      'phone': entity.phone,
      'created_at': entity.createdAt?.toIso8601String(),
      'updated_at': entity.updatedAt?.toIso8601String(),
      'synced_at': entity.syncedAt?.toIso8601String(),
      'dirty': entity.isDirty ? 1 : 0,
    };
  }

  /// Searches people by name or email
  Future<List<CachedPerson>> search(String query) async {
    final searchQuery = '%$query%';
    return getWhere(
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [searchQuery, searchQuery],
      orderBy: 'name ASC',
    );
  }

  /// Gets people by email
  Future<CachedPerson?> getByEmail(String email) async {
    final results = await getWhere(
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}

/// {@template cached_person}
/// Person entity with local caching support.
/// {@endtemplate}
class CachedPerson extends CachedEntity {
  /// {@macro cached_person}
  const CachedPerson({
    required super.id,
    required this.name,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
    super.syncedAt,
    super.isDirty,
  });

  /// Creates from API Person model
  factory CachedPerson.fromPerson(Person person, {bool isDirty = false}) {
    return CachedPerson(
      id: person.id,
      name: person.name,
      email: person.email,
      phone: person.phone,
      createdAt: person.createdAt,
      updatedAt: person.updatedAt,
      isDirty: isDirty,
    );
  }

  /// Full name of the person
  final String name;

  /// Email address
  final String? email;

  /// Phone number
  final String? phone;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts to API Person model
  Person toPerson() {
    return Person(
      id: id,
      name: name,
      email: email,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'dirty': isDirty ? 1 : 0,
    };
  }

  @override
  CachedPerson copyWithSync({
    DateTime? syncedAt,
    bool? isDirty,
  }) {
    return CachedPerson(
      id: id,
      name: name,
      email: email,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  /// Creates a copy with updated information
  CachedPerson copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    bool? isDirty,
  }) {
    return CachedPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String toString() {
    return 'CachedPerson(id: $id, name: $name, email: $email, isDirty: $isDirty)';
  }
}