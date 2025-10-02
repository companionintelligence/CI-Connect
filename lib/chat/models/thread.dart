/// Thread model for chat conversations
class Thread {
  /// Creates a [Thread] instance.
  const Thread({
    required this.id,
    required this.name,
    required this.model,
    this.description,
    this.files = const [],
  });

  /// Creates a [Thread] from a JSON map.
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      description: json['description'] as String?,
      files: json['files'] is List
          ? (json['files'] as List).cast<String>()
          : <String>[],
    );
  }

  /// Unique identifier for the thread
  final String id;

  /// Name of the thread
  final String name;

  /// Model used for this thread
  final String model;

  /// Optional description
  final String? description;

  /// Files associated with this thread
  final List<String> files;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'model': model,
      if (description != null) 'description': description,
      'files': files,
    };
  }

  @override
  String toString() {
    return 'Thread(id: $id, name: $name, model: $model, description: $description, files: $files)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Thread && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
