/// {@template api_client}
/// API Client for CI-Connect that integrates with CI-Server endpoints.
/// {@endtemplate}
import 'package:api_client/src/services/services.dart';
import 'package:dio/dio.dart';

/// {@template api_client}
/// CI Server API client for Companion Intelligence connectivity.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    String? ciServerBaseUrl,
    Dio? httpClient,
  })  : _ciServerBaseUrl = ciServerBaseUrl ?? 'https://api.companion-intelligence.com',
        _dio = httpClient ?? Dio(),
        _calendarSyncService = CalendarSyncService(
          apiClient: CIServerApiClient(
            baseUrl: ciServerBaseUrl ?? 'https://api.companion-intelligence.com',
          ),
        );
  final String _ciServerBaseUrl;
  final Dio _dio;
  final CalendarSyncService _calendarSyncService;

  /// Get CI-Server base URL
  String get ciServerBaseUrl => _ciServerBaseUrl;

  /// Gets the calendar sync service for managing calendar synchronization.
  CalendarSyncService get calendarSync => _calendarSyncService;

  /// Generate a unique ID
  String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + DateTime.now().microsecond) % 1000000;
    return '${timestamp}_$random';
  }

  /// Checks if CI Server is reachable.
  Future<bool> isConnectedToCiServer() async {
    try {
      final response = await _dio.get(
        '$_ciServerBaseUrl/health',
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Gets CI Server status information.
  Future<Map<String, dynamic>?> getCiServerStatus() async {
    try {
      final response = await _dio.get(
        '$_ciServerBaseUrl/api/status',
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sends data to CI Server.
  Future<bool> sendDataToCiServer(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/data',
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // CI Server API Endpoints

  /// Gets people data from CI Server.
  Future<List<Map<String, dynamic>>?> getPeople({
    int? limit,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '$_ciServerBaseUrl/api/people',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Creates or updates a person in CI Server.
  Future<Map<String, dynamic>?> createPerson(Map<String, dynamic> personData) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/people',
        data: personData,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets places data from CI Server.
  Future<List<Map<String, dynamic>>?> getPlaces({
    int? limit,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '$_ciServerBaseUrl/api/places',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Creates or updates a place in CI Server.
  Future<Map<String, dynamic>?> createPlace(Map<String, dynamic> placeData) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/places',
        data: placeData,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets content data from CI Server.
  Future<List<Map<String, dynamic>>?> getContent({
    int? limit,
    String? search,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        '$_ciServerBaseUrl/api/content',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Creates or updates content in CI Server.
  Future<Map<String, dynamic>?> createContent(Map<String, dynamic> contentData) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/content',
        data: contentData,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets contact data from CI Server.
  Future<List<Map<String, dynamic>>?> getContact({
    int? limit,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '$_ciServerBaseUrl/api/contact',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Creates or updates contact in CI Server.
  Future<Map<String, dynamic>?> createContact(Map<String, dynamic> contactData) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/contact',
        data: contactData,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets things data from CI Server.
  Future<List<Map<String, dynamic>>?> getThings({
    int? limit,
    String? search,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get(
        '$_ciServerBaseUrl/api/things',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data as List);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Creates or updates a thing in CI Server.
  Future<Map<String, dynamic>?> createThing(Map<String, dynamic> thingData) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/things',
        data: thingData,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
