import 'package:dio/dio.dart';

import 'ci_server_client.dart';

/// {@template api_client}
/// HTTP API client for CI-Server communication
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    required String baseUrl,
    String? apiKey,
    Dio? dio,
  }) : _ciServerClient = CIServerClient(
          dio: dio ?? Dio(),
          baseUrl: baseUrl,
          apiKey: apiKey,
        );

  final CIServerClient _ciServerClient;

  /// Gets the CI-Server client instance
  CIServerClient get ciServerClient => _ciServerClient;

  /// Generates a new unique ID
  String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + DateTime.now().microsecond) % 1000000;
    return '${timestamp}_$random';
  }
}
