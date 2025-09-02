/// {@template sync_record}
/// Tracks synchronization status for entities.
/// {@endtemplate}
class SyncRecord {
  /// {@macro sync_record}
  const SyncRecord({
    required this.entityId,
    required this.entityType,
    required this.action,
    this.syncedAt,
    this.error,
    this.retryCount = 0,
  });

  /// Creates a [SyncRecord] from a database map.
  factory SyncRecord.fromDatabaseMap(Map<String, dynamic> map) {
    return SyncRecord(
      entityId: map['entity_id'] as String,
      entityType: map['entity_type'] as String,
      action: SyncAction.values.firstWhere(
        (e) => e.name == map['action'] as String,
      ),
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
      error: map['error'] as String?,
      retryCount: map['retry_count'] as int? ?? 0,
    );
  }

  /// The ID of the entity being synced
  final String entityId;

  /// The type of entity (person, place, content, etc.)
  final String entityType;

  /// The sync action to perform
  final SyncAction action;

  /// When this was successfully synced
  final DateTime? syncedAt;

  /// Any error that occurred during sync
  final String? error;

  /// Number of retry attempts
  final int retryCount;

  /// Whether this sync is pending
  bool get isPending => syncedAt == null && error == null;

  /// Whether this sync failed
  bool get hasFailed => error != null;

  /// Whether this sync succeeded
  bool get isSuccessful => syncedAt != null && error == null;

  /// Converts to a map for database storage
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'entity_id': entityId,
      'entity_type': entityType,
      'action': action.name,
      'synced_at': syncedAt?.toIso8601String(),
      'error': error,
      'retry_count': retryCount,
    };
  }

  /// Creates a copy with updated information
  SyncRecord copyWith({
    String? entityId,
    String? entityType,
    SyncAction? action,
    DateTime? syncedAt,
    String? error,
    int? retryCount,
  }) {
    return SyncRecord(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      syncedAt: syncedAt ?? this.syncedAt,
      error: error ?? this.error,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  String toString() {
    return 'SyncRecord(entityId: $entityId, entityType: $entityType, '
        'action: $action, isPending: $isPending, hasFailed: $hasFailed)';
  }
}

/// Actions that can be performed during sync
enum SyncAction {
  /// Create a new entity on the server
  create,
  
  /// Update an existing entity on the server
  update,
  
  /// Delete an entity from the server
  delete,
}