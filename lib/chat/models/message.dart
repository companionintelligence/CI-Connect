import 'package:api_client/api_client.dart';

/// {@template message}
/// Message model for chat messages
/// {@endtemplate}
class Message {
  /// {@macro message}
  const Message({
    required this.id,
    required this.model,
    required this.role,
    required this.content,
    required this.mimetype,
    this.toolCalls,
    required this.canceled,
    this.promptMessage,
  });

  /// Creates a [Message] from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: JsonUtils.parseString(json['id']),
      model: JsonUtils.parseString(json['model']),
      role: JsonUtils.parseString(json['role']),
      content: JsonUtils.parseString(json['content']),
      mimetype: JsonUtils.parseString(json['mimetype']),
      toolCalls: json['toolCalls'] != null
          ? JsonUtils.parseString(json['toolCalls'])
          : null,
      canceled: JsonUtils.parseBool(json['canceled']),
      promptMessage: json['promptMessage'] != null
          ? JsonUtils.parseString(json['promptMessage'])
          : null,
    );
  }

  /// Unique identifier for the message
  final String id;

  /// Model used for the message
  final String model;

  /// Role of the message (assistant, user, system)
  final String role;

  /// Content of the message
  final String content;

  /// MIME type of the content
  final String mimetype;

  /// Tool calls associated with the message
  final String? toolCalls;

  /// Whether the message was canceled
  final bool canceled;

  /// Prompt message if applicable
  final String? promptMessage;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'model': model,
      'role': role,
      'content': content,
      'mimetype': mimetype,
      'toolCalls': toolCalls,
      'canceled': canceled,
      'promptMessage': promptMessage,
    };
  }

  @override
  String toString() {
    return 'Message(id: $id, model: $model, role: $role, content: $content, mimetype: $mimetype, toolCalls: $toolCalls, canceled: $canceled, promptMessage: $promptMessage)';
  }
}
