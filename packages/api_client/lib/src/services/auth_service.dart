import 'package:api_client/src/models/auth_credentials.dart';
import 'package:api_client/src/models/auth_session.dart';
import 'package:api_client/src/utils/json_utils.dart';
import 'package:dio/dio.dart';

/// Authentication service for CI-Server API
class AuthService {
  /// Creates an [AuthService] instance.
  AuthService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String baseUrl;
  final Dio _dio;

  /// Authenticates user with username and password
  Future<AuthSession> authenticate(AuthCredentials credentials) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/authenticate',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: credentials.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthSession.fromJson(response.data!);
      } else {
        throw AuthException('Authentication failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Try to get error message from response
        final errorMessage =
            _extractErrorMessage(e.response?.data) ?? 'Invalid credentials';
        throw AuthException(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AuthException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const AuthException(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else {
        final errorMessage =
            _extractErrorMessage(e.response?.data) ??
            e.message ??
            'Authentication failed';
        throw AuthException(errorMessage);
      }
    } catch (e) {
      throw AuthException('Unexpected error during authentication: $e');
    }
  }

  /// Extracts error message from API response
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try different common error message fields
      final message = JsonUtils.parseString(responseData['message']);
      if (message.isNotEmpty) return message;

      final error = JsonUtils.parseString(responseData['error']);
      if (error.isNotEmpty) return error;

      final detail = JsonUtils.parseString(responseData['detail']);
      if (detail.isNotEmpty) return detail;
    }
    return null;
  }

  /// Validates if the current session is still valid
  Future<bool> validateSession(String sessionToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/api/validate-session',
        options: Options(
          headers: {
            'Authorization': 'Bearer $sessionToken',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Refreshes the access token using the session token
  Future<String> refreshAccessToken(String sessionToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/api/refresh-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $sessionToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!['accessToken'] as String;
      } else {
        throw AuthException('Token refresh failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Session expired. Please log in again.');
      } else {
        throw AuthException('Token refresh failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Unexpected error during token refresh: $e');
    }
  }

  /// Logs out the user by invalidating the session
  Future<void> logout(String sessionToken) async {
    try {
      await _dio.post<void>(
        '$baseUrl/api/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $sessionToken',
          },
        ),
      );
    } catch (e) {
      // Logout should not throw errors even if the server is unreachable
      // The local session will be cleared regardless
    }
  }
}

/// Exception thrown by authentication operations
class AuthException implements Exception {
  /// Creates an [AuthException] instance.
  const AuthException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
