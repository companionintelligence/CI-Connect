/// Thing model for CI-Server API
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
  factory Thing.fromJson(Map<String, dynamic> json) {
    return Thing(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      properties: json['properties'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

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
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (properties != null) 'properties': properties,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Thing(id: $id, name: $name, category: $category)';
  }
}