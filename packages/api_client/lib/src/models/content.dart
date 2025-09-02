import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

/// Content model for CI-Server API
@JsonSerializable()
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
  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);

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
  Map<String, dynamic> toJson() => _$ContentToJson(this);

  @override
  String toString() {
    return 'Content(id: $id, name: $name, type: $type, mimeType: $mimeType)';
  }
}