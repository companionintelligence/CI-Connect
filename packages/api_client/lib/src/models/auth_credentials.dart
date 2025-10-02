/// Authentication credentials model
class AuthCredentials {
  /// Creates an [AuthCredentials] instance.
  const AuthCredentials({
    required this.username,
    required this.password,
  });

  /// Username for authentication
  final String username;

  /// Password for authentication
  final String password;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'AuthCredentials(username: $username, password: [HIDDEN])';
  }
}
