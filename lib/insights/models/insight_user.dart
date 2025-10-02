import 'package:api_client/src/utils/json_utils.dart';

/// Model for insight user
class InsightUser {
  /// Creates an [InsightUser] instance.
  const InsightUser({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Creates an [InsightUser] from a JSON map.
  factory InsightUser.fromJson(Map<String, dynamic> json) {
    return InsightUser(
      id: JsonUtils.parseString(json['id']),
      name: JsonUtils.parseString(json['name']),
      email: JsonUtils.parseString(json['email']),
    );
  }

  /// User ID
  final String id;

  /// User name
  final String name;

  /// User email
  final String email;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'InsightUser(id: $id, name: $name, email: $email)';
  }
}
