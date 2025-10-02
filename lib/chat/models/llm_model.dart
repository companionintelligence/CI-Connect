/// LLM Model for available AI models
class LLMModel {
  /// Creates an [LLMModel] instance.
  const LLMModel({
    required this.id,
    required this.name,
    this.description,
    this.version,
  });

  /// Creates an [LLMModel] from a JSON map.
  factory LLMModel.fromJson(Map<String, dynamic> json) {
    return LLMModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      version: json['version'] as String?,
    );
  }

  /// Unique identifier for the model
  final String id;

  /// Name of the model
  final String name;

  /// Optional description
  final String? description;

  /// Optional version
  final String? version;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (version != null) 'version': version,
    };
  }

  @override
  String toString() {
    return 'LLMModel(id: $id, name: $name, description: $description, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LLMModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
