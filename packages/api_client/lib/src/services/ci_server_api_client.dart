import 'package:dio/dio.dart';

/// {@template ci_server_api_client}
/// HTTP client for communicating with the CI-Server API.
/// {@endtemplate}
class CIServerApiClient {
  /// {@macro ci_server_api_client}
  CIServerApiClient({
    required String baseUrl,
    Dio? dio,
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  final Dio _dio;
  final String _baseUrl;

  /// Get all items from a specific endpoint.
  Future<List<Map<String, dynamic>>> getAll(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      } else if (response.data is Map && response.data['data'] is List) {
        return List<Map<String, dynamic>>.from(response.data['data'] as List);
      } else {
        return [Map<String, dynamic>.from(response.data as Map)];
      }
    } on DioException catch (e) {
      throw CIServerApiException('Failed to get $endpoint: ${e.message}', e);
    }
  }

  /// Get a specific item by ID from an endpoint.
  Future<Map<String, dynamic>> getById(
    String endpoint,
    String id,
  ) async {
    try {
      final response = await _dio.get('$endpoint/$id');
      
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw CIServerApiException('Invalid response format for $endpoint/$id');
      }
    } on DioException catch (e) {
      throw CIServerApiException('Failed to get $endpoint/$id: ${e.message}', e);
    }
  }

  /// Create a new item at the specified endpoint.
  Future<Map<String, dynamic>> create(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw CIServerApiException('Invalid response format for POST $endpoint');
      }
    } on DioException catch (e) {
      throw CIServerApiException('Failed to create $endpoint: ${e.message}', e);
    }
  }

  /// Update an existing item at the specified endpoint.
  Future<Map<String, dynamic>> update(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('$endpoint/$id', data: data);
      
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      } else {
        throw CIServerApiException('Invalid response format for PUT $endpoint/$id');
      }
    } on DioException catch (e) {
      throw CIServerApiException('Failed to update $endpoint/$id: ${e.message}', e);
    }
  }

  /// Delete an item at the specified endpoint.
  Future<void> delete(
    String endpoint,
    String id,
  ) async {
    try {
      await _dio.delete('$endpoint/$id');
    } on DioException catch (e) {
      throw CIServerApiException('Failed to delete $endpoint/$id: ${e.message}', e);
    }
  }

  /// Dispose of resources.
  void dispose() {
    _dio.close();
  }
}

/// Exception thrown when CI-Server API operations fail.
class CIServerApiException implements Exception {
  /// Creates a [CIServerApiException] with the given [message].
  const CIServerApiException(this.message, [this.cause]);

  /// The error message.
  final String message;

  /// The underlying cause of the exception.
  final Object? cause;

  @override
  String toString() => 'CIServerApiException: $message';
}