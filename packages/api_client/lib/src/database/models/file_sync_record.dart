/// {@template file_sync_record}
/// Tracks file synchronization status and metadata.
/// {@endtemplate}
class FileSyncRecord {
  /// {@macro file_sync_record}
  const FileSyncRecord({
    required this.id,
    required this.filePath,
    required this.fileName,
    this.fileSize,
    this.fileType,
    this.mimeType,
    this.checksum,
    this.lastModified,
    this.syncedAt,
    this.syncStatus = FileSyncStatus.pending,
    this.errorMessage,
  });

  /// Creates a [FileSyncRecord] from a database map.
  factory FileSyncRecord.fromDatabaseMap(Map<String, dynamic> map) {
    return FileSyncRecord(
      id: map['id'] as String,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      fileSize: map['file_size'] as int?,
      fileType: map['file_type'] as String?,
      mimeType: map['mime_type'] as String?,
      checksum: map['checksum'] as String?,
      lastModified: map['last_modified'] != null
          ? DateTime.parse(map['last_modified'] as String)
          : null,
      syncedAt: map['synced_at'] != null
          ? DateTime.parse(map['synced_at'] as String)
          : null,
      syncStatus: FileSyncStatus.values.firstWhere(
        (e) => e.name == (map['sync_status'] as String? ?? 'pending'),
        orElse: () => FileSyncStatus.pending,
      ),
      errorMessage: map['error_message'] as String?,
    );
  }

  /// Unique identifier
  final String id;

  /// Full path to the file
  final String filePath;

  /// Name of the file
  final String fileName;

  /// Size of the file in bytes
  final int? fileSize;

  /// Type of file (image, video, document)
  final String? fileType;

  /// MIME type of the file
  final String? mimeType;

  /// File checksum for integrity checking
  final String? checksum;

  /// When the file was last modified
  final DateTime? lastModified;

  /// When the file was successfully synced
  final DateTime? syncedAt;

  /// Current sync status
  final FileSyncStatus syncStatus;

  /// Error message if sync failed
  final String? errorMessage;

  /// Whether this file needs to be synced
  bool get needsSync => 
      syncStatus == FileSyncStatus.pending || 
      syncStatus == FileSyncStatus.failed;

  /// Whether this file is currently being synced
  bool get isSyncing => syncStatus == FileSyncStatus.syncing;

  /// Whether this file has been successfully synced
  bool get isSynced => syncStatus == FileSyncStatus.synced;

  /// Whether this file sync has failed
  bool get hasFailed => syncStatus == FileSyncStatus.failed;

  /// Converts to a map for database storage
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'id': id,
      'file_path': filePath,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'mime_type': mimeType,
      'checksum': checksum,
      'last_modified': lastModified?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'sync_status': syncStatus.name,
      'error_message': errorMessage,
    };
  }

  /// Creates a copy with updated information
  FileSyncRecord copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? mimeType,
    String? checksum,
    DateTime? lastModified,
    DateTime? syncedAt,
    FileSyncStatus? syncStatus,
    String? errorMessage,
  }) {
    return FileSyncRecord(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType,
      checksum: checksum ?? this.checksum,
      lastModified: lastModified ?? this.lastModified,
      syncedAt: syncedAt ?? this.syncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'FileSyncRecord(id: $id, fileName: $fileName, '
        'syncStatus: $syncStatus, needsSync: $needsSync)';
  }
}

/// Status of file synchronization
enum FileSyncStatus {
  /// File is pending sync
  pending,

  /// File is currently being synced
  syncing,

  /// File has been successfully synced
  synced,

  /// File sync failed
  failed,

  /// File was skipped (e.g., too large, unsupported type)
  skipped,
}