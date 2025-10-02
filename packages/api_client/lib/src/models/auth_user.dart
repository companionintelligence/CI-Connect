import 'package:api_client/src/utils/json_utils.dart';

/// Authentication user model
class AuthUser {
  /// Creates an [AuthUser] instance.
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Creates an [AuthUser] from a JSON map.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: JsonUtils.parseString(json['id']),
      name: JsonUtils.parseString(json['name']),
      email: JsonUtils.parseString(json['email']),
    );
  }

  /// Unique identifier for the user
  final String id;

  /// Full name of the user
  final String name;

  /// Email address
  final String email;

  /// Creates a copy of this user with the given fields replaced.
  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
