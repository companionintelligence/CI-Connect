import 'package:api_client/src/models/auth_user.dart';
import 'package:api_client/src/utils/json_utils.dart';

/// Authentication session model
class AuthSession {
  /// Creates an [AuthSession] instance.
  const AuthSession({
    required this.sessionToken,
    required this.accessToken,
    required this.user,
    this.createdAt,
  });

  /// Creates an [AuthSession] from a JSON map.
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      sessionToken: JsonUtils.parseString(json['sessionToken']),
      accessToken: JsonUtils.parseString(json['accessToken']),
      user: _parseUser(json['user']),
      createdAt: JsonUtils.parseDateTime(json['createdAt']),
    );
  }

  /// Safely parses a JSON value to AuthUser
  static AuthUser _parseUser(dynamic value) {
    if (value == null) {
      return const AuthUser(id: '', name: 'Unknown User', email: '');
    }
    if (value is Map<String, dynamic>) {
      return AuthUser.fromJson(value);
    }
    return const AuthUser(id: '', name: 'Unknown User', email: '');
  }

  /// Session token for long-term authentication
  final String sessionToken;

  /// Access token for API requests (refreshed every 5 minutes)
  final String accessToken;

  /// User information
  final AuthUser user;

  /// Session creation timestamp
  final DateTime? createdAt;

  /// Creates a copy of this session with the given fields replaced.
  AuthSession copyWith({
    String? sessionToken,
    String? accessToken,
    AuthUser? user,
    DateTime? createdAt,
  }) {
    return AuthSession(
      sessionToken: sessionToken ?? this.sessionToken,
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionToken': sessionToken,
      'accessToken': accessToken,
      'user': user.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AuthSession(sessionToken: ${sessionToken.substring(0, 20)}..., accessToken: ${accessToken.substring(0, 20)}..., user: $user)';
  }
}
