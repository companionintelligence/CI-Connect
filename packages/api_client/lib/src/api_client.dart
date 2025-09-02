import 'package:api_client/src/notification_service.dart';
import 'package:dio/dio.dart';

/// {@template api_client}
/// API Client for CI-Connect that integrates with CI-Server endpoints.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    String? ciServerUrl,
    Dio? dio,
  }) : _ciServerUrl = ciServerUrl ?? 'https://api.ci-server.com',
       _dio = dio ?? Dio();

  final String _ciServerUrl;
  final Dio _dio;

  /// Creates a notification service instance for CI-Server API.
  NotificationService createNotificationService() {
    return NotificationService(
      baseUrl: _ciServerUrl,
      dio: _dio,
    );
  }

  /// Get CI-Server base URL
  String get ciServerUrl => _ciServerUrl;

  /// Generate a unique ID (replaces Firebase document ID generation)
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
