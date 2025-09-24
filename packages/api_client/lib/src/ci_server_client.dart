import 'dart:async';

import 'package:dio/dio.dart';

import 'models/models.dart';

/// {@template ci_server_client}
/// HTTP client for communicating with CI-Server API
/// {@endtemplate}
class CIServerClient {
  /// {@macro ci_server_client}
  CIServerClient({
    required Dio dio,
    required String baseUrl,
    String? apiKey,
  })  : _dio = dio,
        _baseUrl = baseUrl,
        _apiKey = apiKey {
    // Configure dio with base URL and interceptors
    _dio.options.baseUrl = _baseUrl;
    
    if (_apiKey != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    }
    
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  final Dio _dio;
  final String _baseUrl;
  final String? _apiKey;

  /// Gets a contact by ID
  Future<Map<String, dynamic>?> getContact({
    required String studioId,
    required String contactId,
  }) async {
    try {
      final response = await _dio.get(
        '/contact/$contactId',
        queryParameters: {'studioId': studioId},
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw CIServerException('Failed to get contact: ${e.message}');
    }
  }

  /// Gets all contacts for a studio
  Future<List<Map<String, dynamic>>> getContacts({
    required String studioId,
  }) async {
    try {
      final response = await _dio.get(
        '/contact',
        queryParameters: {'studioId': studioId},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['contacts'] is List) {
          return (data['contacts'] as List).cast<Map<String, dynamic>>();
        }
      }
      
      return [];
    } on DioException catch (e) {
      throw CIServerException('Failed to get contacts: ${e.message}');
    }
  }

  /// Updates a contact with health data
  Future<Map<String, dynamic>> updateContactHealthData({
    required String studioId,
    required String contactId,
    required List<HealthData> healthData,
  }) async {
    try {
      final response = await _dio.put(
        '/contact/$contactId/health-data',
        queryParameters: {'studioId': studioId},
        data: {
          'healthData': healthData.map((h) => h.toJson()).toList(),
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      
      throw CIServerException('Unexpected status code: ${response.statusCode}');
    } on DioException catch (e) {
      throw CIServerException('Failed to update contact health data: ${e.message}');
    }
  }

  /// Gets health data for a contact
  Future<List<HealthData>> getContactHealthData({
    required String studioId,
    required String contactId,
  }) async {
    try {
      final response = await _dio.get(
        '/contact/$contactId/health-data',
        queryParameters: {'studioId': studioId},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> healthDataList = [];
        
        if (data is List) {
          healthDataList = data;
        } else if (data is Map && data['healthData'] is List) {
          healthDataList = data['healthData'] as List;
        }
        
        return healthDataList
            .map((item) => HealthData.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw CIServerException('Failed to get contact health data: ${e.message}');
    }
  }

  /// Creates or updates contact sync data
  Future<void> updateContactSyncData({
    required String studioId,
    required ContactSyncData syncData,
  }) async {
    try {
      await _dio.put(
        '/contact/${syncData.contactId}/sync-status',
        queryParameters: {'studioId': studioId},
        data: syncData.toJson(),
      );
    } on DioException catch (e) {
      throw CIServerException('Failed to update contact sync data: ${e.message}');
    }
  }

  /// Gets contact sync status
  Future<ContactSyncData?> getContactSyncData({
    required String studioId,
    required String contactId,
  }) async {
    try {
      final response = await _dio.get(
        '/contact/$contactId/sync-status',
        queryParameters: {'studioId': studioId},
      );
      
      if (response.statusCode == 200) {
        return ContactSyncData.fromJson(response.data as Map<String, dynamic>);
      }
      
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw CIServerException('Failed to get contact sync data: ${e.message}');
    }
  }

  /// Gets sync status for all contacts in a studio
  Future<List<ContactSyncData>> getAllContactsSyncData({
    required String studioId,
  }) async {
    try {
      final response = await _dio.get(
        '/contact/sync-status',
        queryParameters: {'studioId': studioId},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> syncDataList = [];
        
        if (data is List) {
          syncDataList = data;
        } else if (data is Map && data['syncData'] is List) {
          syncDataList = data['syncData'] as List;
        }
        
        return syncDataList
            .map((item) => ContactSyncData.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw CIServerException('Failed to get all contacts sync data: ${e.message}');
    }
  }

  /// Creates a contact in CI-Server
  Future<Map<String, dynamic>?> createContact({
    required String studioId,
    required Map<String, dynamic> contactData,
  }) async {
    try {
      final response = await _dio.post(
        '/contact',
        data: {
          ...contactData,
          'studioId': studioId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }
      
      return null;
    } on DioException catch (e) {
      throw CIServerException('Failed to create contact: ${e.message}');
    }
  }

  /// Creates a person in CI-Server
  Future<Map<String, dynamic>?> createPerson({
    required String studioId,
    required Map<String, dynamic> personData,
  }) async {
    try {
      final response = await _dio.post(
        '/people',
        data: {
          ...personData,
          'studioId': studioId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }
      
      return null;
    } on DioException catch (e) {
      throw CIServerException('Failed to create person: ${e.message}');
    }
  }

  /// Creates content in CI-Server
  Future<Map<String, dynamic>?> createContent({
    required String studioId,
    required Map<String, dynamic> contentData,
  }) async {
    try {
      final response = await _dio.post(
        '/content',
        data: {
          ...contentData,
          'studioId': studioId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }
      
      return null;
    } on DioException catch (e) {
      throw CIServerException('Failed to create content: ${e.message}');
    }
  }

  /// Creates a place in CI-Server
  Future<Map<String, dynamic>?> createPlace({
    required String studioId,
    required Map<String, dynamic> placeData,
  }) async {
    try {
      final response = await _dio.post(
        '/places',
        data: {
          ...placeData,
          'studioId': studioId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>?;
      }
      
      return null;
    } on DioException catch (e) {
      throw CIServerException('Failed to create place: ${e.message}');
    }
  }
}

/// Exception thrown when CI-Server API operations fail
class CIServerException implements Exception {
  /// Creates a [CIServerException]
  const CIServerException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'CIServerException: $message';
}