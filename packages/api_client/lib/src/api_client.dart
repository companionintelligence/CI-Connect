import 'package:api_client/src/firebase_extensions.dart';
import 'package:api_client/src/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

/// {@template api_client}
/// API Client for CI-Connect that supports both Firebase and CI-Server endpoints.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    required FirebaseFirestore firestore,
    String? ciServerUrl,
    Dio? dio,
  }) : _firestore = firestore,
       _ciServerUrl = ciServerUrl ?? 'https://api.ci-server.com',
       _dio = dio ?? Dio();

  final FirebaseFirestore _firestore;
  final String _ciServerUrl;
  final Dio _dio;

  /// Generates a new firestore document ID.
  String generateId() => _firestore.generateId();

  /// Creates a notification service instance for CI-Server API.
  NotificationService createNotificationService() {
    return NotificationService(
      baseUrl: _ciServerUrl,
      dio: _dio,
    );
  }

  /// Get CI-Server base URL
  String get ciServerUrl => _ciServerUrl;
}
