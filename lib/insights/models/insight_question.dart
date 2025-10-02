import 'package:api_client/src/utils/json_utils.dart';

/// Model for insight question
class InsightQuestion {
  /// Creates an [InsightQuestion] instance.
  const InsightQuestion({
    required this.id,
    required this.category,
    required this.text,
    required this.answer,
  });

  /// Creates an [InsightQuestion] from a JSON map.
  factory InsightQuestion.fromJson(Map<String, dynamic> json) {
    return InsightQuestion(
      id: JsonUtils.parseString(json['id']),
      category: JsonUtils.parseString(json['category']),
      text: JsonUtils.parseString(json['text']),
      answer: JsonUtils.parseString(json['answer']),
    );
  }

  /// Question ID
  final String id;

  /// Question category
  final String category;

  /// Question text
  final String text;

  /// User's answer
  final String answer;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'text': text,
      'answer': answer,
    };
  }

  @override
  String toString() {
    return 'InsightQuestion(id: $id, category: $category, text: $text)';
  }
}
