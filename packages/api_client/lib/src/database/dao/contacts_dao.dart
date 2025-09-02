import '../models/models.dart';
import '../../models/models.dart';
import 'base_dao.dart';

/// {@template contacts_dao}
/// Data Access Object for Contact entities with caching support.
/// {@endtemplate}
class ContactsDao extends BaseDao<CachedContact> {
  /// {@macro contacts_dao}
  ContactsDao() : super('contacts');

  @override
  CachedContact fromDatabaseMap(Map<String, dynamic> map) {
    return CachedContact(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      company: map['company'] as String?,
      notes: map['notes'] as String?,
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
  Map<String, dynamic> toDatabaseMap(CachedContact entity) {
    return <String, dynamic>{
      'id': entity.id,
      'name': entity.name,
      'email': entity.email,
      'phone': entity.phone,
      'company': entity.company,
      'notes': entity.notes,
      'created_at': entity.createdAt?.toIso8601String(),
      'updated_at': entity.updatedAt?.toIso8601String(),
      'synced_at': entity.syncedAt?.toIso8601String(),
      'dirty': entity.isDirty ? 1 : 0,
    };
  }

  /// Searches contacts by name, email, or company
  Future<List<CachedContact>> search(String query) async {
    final searchQuery = '%$query%';
    return getWhere(
      where: 'name LIKE ? OR email LIKE ? OR company LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'name ASC',
    );
  }

  /// Gets contacts by company
  Future<List<CachedContact>> getByCompany(String company) async {
    return getWhere(
      where: 'company = ?',
      whereArgs: [company],
      orderBy: 'name ASC',
    );
  }

  /// Gets contact by email
  Future<CachedContact?> getByEmail(String email) async {
    final results = await getWhere(
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}

/// {@template cached_contact}
/// Contact entity with local caching support.
/// {@endtemplate}
class CachedContact extends CachedEntity {
  /// {@macro cached_contact}
  const CachedContact({
    required super.id,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.notes,
    this.createdAt,
    this.updatedAt,
    super.syncedAt,
    super.isDirty,
  });

  /// Full name of the contact
  final String name;

  /// Email address
  final String? email;

  /// Phone number
  final String? phone;

  /// Company name
  final String? company;

  /// Additional notes
  final String? notes;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts to API Contact model
  Contact toContact() {
    return Contact(
      id: id,
      name: name,
      email: email,
      phone: phone,
      company: company,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates from API Contact model
  factory CachedContact.fromContact(Contact contact, {bool isDirty = false}) {
    return CachedContact(
      id: contact.id,
      name: contact.name,
      email: contact.email,
      phone: contact.phone,
      company: contact.company,
      notes: contact.notes,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
      isDirty: isDirty,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'dirty': isDirty ? 1 : 0,
    };
  }

  @override
  CachedContact copyWithSync({
    DateTime? syncedAt,
    bool? isDirty,
  }) {
    return CachedContact(
      id: id,
      name: name,
      email: email,
      phone: phone,
      company: company,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  /// Creates a copy with updated information
  CachedContact copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    bool? isDirty,
  }) {
    return CachedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String toString() {
    return 'CachedContact(id: $id, name: $name, email: $email, '
        'company: $company, isDirty: $isDirty)';
  }
}