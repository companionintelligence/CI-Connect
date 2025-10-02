import 'package:api_client/src/models/auth_credentials.dart';
import 'package:api_client/src/models/auth_session.dart';
import 'package:api_client/src/services/auth_service.dart';

/// {@template auth_repository}
/// Repository for managing authentication operations
/// {@endtemplate}
abstract class AuthRepository {
  /// Authenticates user with username and password
  Future<AuthSession> authenticate(AuthCredentials credentials);

  /// Validates if the current session is still valid
  Future<bool> validateSession(String sessionToken);

  /// Refreshes the access token using the session token
  Future<String> refreshAccessToken(String sessionToken);

  /// Logs out the user by invalidating the session
  Future<void> logout(String sessionToken);
}

/// {@template api_auth_repository}
/// API implementation of [AuthRepository]
/// {@endtemplate}
class ApiAuthRepository implements AuthRepository {
  /// {@macro api_auth_repository}
  ApiAuthRepository({
    required AuthService authService,
  }) : _authService = authService;

  final AuthService _authService;

  @override
  Future<AuthSession> authenticate(AuthCredentials credentials) async {
    return _authService.authenticate(credentials);
  }

  @override
  Future<bool> validateSession(String sessionToken) async {
    return _authService.validateSession(sessionToken);
  }

  @override
  Future<String> refreshAccessToken(String sessionToken) async {
    return _authService.refreshAccessToken(sessionToken);
  }

  @override
  Future<void> logout(String sessionToken) async {
    return _authService.logout(sessionToken);
  }
}
