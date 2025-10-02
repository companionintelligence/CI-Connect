import 'package:api_client/src/utils/json_utils.dart';

import 'package:companion_connect/insights/models/insight_question.dart';
import 'package:companion_connect/insights/models/insight_user.dart';

/// Model for insight
class Insight {
  /// Creates an [Insight] instance.
  const Insight({
    required this.id,
    required this.ragAnswer,
    required this.answer,
    required this.user,
    required this.question,
  });

  /// Creates an [Insight] from a JSON map.
  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: JsonUtils.parseString(json['id']),
      ragAnswer: JsonUtils.parseString(json['ragAnswer']),
      answer: JsonUtils.parseString(json['answer']),
      user: _parseUser(json['user']),
      question: _parseQuestion(json['question']),
    );
  }

  /// Safely parses a JSON value to InsightUser
  static InsightUser _parseUser(dynamic value) {
    if (value == null) {
      return const InsightUser(id: '', name: 'Unknown User', email: '');
    }
    if (value is Map<String, dynamic>) {
      return InsightUser.fromJson(value);
    }
    return const InsightUser(id: '', name: 'Unknown User', email: '');
  }

  /// Safely parses a JSON value to InsightQuestion
  static InsightQuestion _parseQuestion(dynamic value) {
    if (value == null) {
      return const InsightQuestion(
        id: '',
        category: 'Unknown',
        text: 'No question available',
        answer: '',
      );
    }
    if (value is Map<String, dynamic>) {
      return InsightQuestion.fromJson(value);
    }
    return const InsightQuestion(
      id: '',
      category: 'Unknown',
      text: 'No question available',
      answer: '',
    );
  }

  /// Insight ID
  final String id;

  /// RAG (AI) answer
  final String ragAnswer;

  /// User's answer
  final String answer;

  /// User information
  final InsightUser user;

  /// Question information
  final InsightQuestion question;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ragAnswer': ragAnswer,
      'answer': answer,
      'user': user.toJson(),
      'question': question.toJson(),
    };
  }

  @override
  String toString() {
    return 'Insight(id: $id, category: ${question.category}, question: ${question.text})';
  }
}
