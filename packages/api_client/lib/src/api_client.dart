import 'package:dio/dio.dart';

/// {@template api_client}
/// CI-Connect API Client for CI-Server integration.
/// Provides access to people, places, content, contact, and things endpoints.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    required String baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  final Dio _dio;

  /// Get people endpoint
  Future<Response<dynamic>> getPeople({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    return _dio.get(
      '/people',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (filters != null) ...filters,
      },
    );
  }

  /// Create a person
  Future<Response<dynamic>> createPerson(Map<String, dynamic> data) async {
    return _dio.post('/people', data: data);
  }

  /// Get person by ID
  Future<Response<dynamic>> getPerson(String id) async {
    return _dio.get('/people/$id');
  }

  /// Update person
  Future<Response<dynamic>> updatePerson(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _dio.put('/people/$id', data: data);
  }

  /// Delete person
  Future<Response<dynamic>> deletePerson(String id) async {
    return _dio.delete('/people/$id');
  }

  /// Get places endpoint
  Future<Response<dynamic>> getPlaces({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    return _dio.get(
      '/places',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (filters != null) ...filters,
      },
    );
  }

  /// Create a place
  Future<Response<dynamic>> createPlace(Map<String, dynamic> data) async {
    return _dio.post('/places', data: data);
  }

  /// Get place by ID
  Future<Response<dynamic>> getPlace(String id) async {
    return _dio.get('/places/$id');
  }

  /// Update place
  Future<Response<dynamic>> updatePlace(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _dio.put('/places/$id', data: data);
  }

  /// Delete place
  Future<Response<dynamic>> deletePlaces(String id) async {
    return _dio.delete('/places/$id');
  }

  /// Get content endpoint
  Future<Response<dynamic>> getContent({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    return _dio.get(
      '/content',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (filters != null) ...filters,
      },
    );
  }

  /// Create content
  Future<Response<dynamic>> createContent(Map<String, dynamic> data) async {
    return _dio.post('/content', data: data);
  }

  /// Get content by ID
  Future<Response<dynamic>> getContentById(String id) async {
    return _dio.get('/content/$id');
  }

  /// Update content
  Future<Response<dynamic>> updateContent(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _dio.put('/content/$id', data: data);
  }

  /// Delete content
  Future<Response<dynamic>> deleteContent(String id) async {
    return _dio.delete('/content/$id');
  }

  /// Upload file content
  Future<Response<dynamic>> uploadContent(
    String filePath,
    Map<String, dynamic> metadata,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'metadata': metadata,
    });
    
    return _dio.post('/content/upload', data: formData);
  }

  /// Get contacts endpoint
  Future<Response<dynamic>> getContacts({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    return _dio.get(
      '/contact',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (filters != null) ...filters,
      },
    );
  }

  /// Create a contact
  Future<Response<dynamic>> createContact(Map<String, dynamic> data) async {
    return _dio.post('/contact', data: data);
  }

  /// Get contact by ID
  Future<Response<dynamic>> getContact(String id) async {
    return _dio.get('/contact/$id');
  }

  /// Update contact
  Future<Response<dynamic>> updateContact(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _dio.put('/contact/$id', data: data);
  }

  /// Delete contact
  Future<Response<dynamic>> deleteContact(String id) async {
    return _dio.delete('/contact/$id');
  }

  /// Get things endpoint
  Future<Response<dynamic>> getThings({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    return _dio.get(
      '/things',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (filters != null) ...filters,
      },
    );
  }

  /// Create a thing
  Future<Response<dynamic>> createThing(Map<String, dynamic> data) async {
    return _dio.post('/things', data: data);
  }

  /// Get thing by ID
  Future<Response<dynamic>> getThing(String id) async {
    return _dio.get('/things/$id');
  }

  /// Update thing
  Future<Response<dynamic>> updateThing(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _dio.put('/things/$id', data: data);
  }

  /// Delete thing
  Future<Response<dynamic>> deleteThing(String id) async {
    return _dio.delete('/things/$id');
  }
}
