/// Content model for CI-Server API
class Content {
  /// Creates a [Content] instance.
  const Content({
    required this.id,
    required this.name,
    required this.type,
    this.filePath,
    this.fileSize,
    this.mimeType,
    this.description,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Content] from a JSON map.
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      filePath: json['filePath'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      description: json['description'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Unique identifier for the content
  final String id;

  /// Name of the content
  final String name;

  /// Type of content (image, video, document)
  final String type;

  /// Path to the file on server
  final String? filePath;

  /// Size of the file in bytes
  final int? fileSize;

  /// MIME type of the file
  final String? mimeType;

  /// Description of the content
  final String? description;

  /// Tags associated with the content
  final List<String>? tags;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      if (filePath != null) 'filePath': filePath,
      if (fileSize != null) 'fileSize': fileSize,
      if (mimeType != null) 'mimeType': mimeType,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Content(id: $id, name: $name, type: $type, mimeType: $mimeType)';
  }
}