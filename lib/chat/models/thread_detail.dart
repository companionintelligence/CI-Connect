import 'package:api_client/api_client.dart';
import 'package:companion_connect/chat/models/message.dart';

/// {@template thread_detail}
/// ThreadDetail model for thread with messages
/// {@endtemplate}
class ThreadDetail {
  /// {@macro thread_detail}
  const ThreadDetail({
    required this.id,
    required this.name,
    required this.model,
    this.description,
    required this.files,
    required this.messages,
  });

  /// Creates a [ThreadDetail] from a JSON map.
  factory ThreadDetail.fromJson(Map<String, dynamic> json) {
    return ThreadDetail(
      id: JsonUtils.parseString(json['id']),
      name: JsonUtils.parseString(json['name']),
      model: JsonUtils.parseString(json['model']),
      description: json['description'] != null
          ? JsonUtils.parseString(json['description'])
          : null,
      files: JsonUtils.parseList(
        json['files'],
        (dynamic item) => JsonUtils.parseString(item),
      ),
      messages: JsonUtils.parseList(
        json['messages'],
        (dynamic item) => Message.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  /// Unique identifier for the thread
  final String id;

  /// Name of the thread
  final String name;

  /// Model used for the thread
  final String model;

  /// Description of the thread
  final String? description;

  /// List of files associated with the thread
  final List<String> files;

  /// List of messages in the thread
  final List<Message> messages;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'model': model,
      'description': description,
      'files': files,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ThreadDetail(id: $id, name: $name, model: $model, description: $description, files: ${files.length}, messages: ${messages.length})';
  }
}
