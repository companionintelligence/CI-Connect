import 'package:json_annotation/json_annotation.dart';

part 'thing.g.dart';

/// Thing model for CI-Server API
@JsonSerializable()
class Thing {
  /// Creates a [Thing] instance.
  const Thing({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.properties,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Thing] from a JSON map.
  factory Thing.fromJson(Map<String, dynamic> json) => _$ThingFromJson(json);

  /// Unique identifier for the thing
  final String id;

  /// Name of the thing
  final String name;

  /// Category classification
  final String? category;

  /// Description of the thing
  final String? description;

  /// Additional properties as key-value pairs
  final Map<String, dynamic>? properties;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$ThingToJson(this);

  @override
  String toString() {
    return 'Thing(id: $id, name: $name, category: $category)';
  }
}