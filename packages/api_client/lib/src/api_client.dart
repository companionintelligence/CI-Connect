/// {@template api_client}
/// API Client for CI-Connect that integrates with CI-Server endpoints.
import 'package:api_client/src/notification_service.dart';
import 'package:dio/dio.dart';
import 'models/models.dart';

/// {@template api_client}
/// CI-Connect API Client for CI-Server integration.
/// Provides access to people, places, content, contact, and things endpoints.

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

  // People endpoints

  /// Get all people with optional filtering and pagination
  Future<List<Person>> getPeople({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/people',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Person.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to get people: $e');
    }
  }

  /// Create a new person
  Future<Person> createPerson(Person person) async {
    try {
      final response = await _dio.post('/people', data: person.toJson());
      return Person.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to create person: $e');
    }
  }

  /// Get person by ID
  Future<Person> getPerson(String id) async {
    try {
      final response = await _dio.get('/people/$id');
      return Person.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to get person: $e');
    }
  }

  /// Update a person
  Future<Person> updatePerson(String id, Person person) async {
    try {
      final response = await _dio.put('/people/$id', data: person.toJson());
      return Person.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to update person: $e');
    }
  }

  /// Delete a person
  Future<void> deletePerson(String id) async {
    try {
      await _dio.delete('/people/$id');
    } catch (e) {
      throw ApiException('Failed to delete person: $e');
    }
  }

  // Places endpoints

  /// Get all places with optional filtering and pagination
  Future<List<Place>> getPlaces({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/places',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Place.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to get places: $e');
    }
  }

  /// Create a new place
  Future<Place> createPlace(Place place) async {
    try {
      final response = await _dio.post('/places', data: place.toJson());
      return Place.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to create place: $e');
    }
  }

  /// Get place by ID
  Future<Place> getPlace(String id) async {
    try {
      final response = await _dio.get('/places/$id');
      return Place.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to get place: $e');
    }
  }

  /// Update a place
  Future<Place> updatePlace(String id, Place place) async {
    try {
      final response = await _dio.put('/places/$id', data: place.toJson());
      return Place.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to update place: $e');
    }
  }

  /// Delete a place
  Future<void> deletePlace(String id) async {
    try {
      await _dio.delete('/places/$id');
    } catch (e) {
      throw ApiException('Failed to delete place: $e');
    }
  }

  // Content endpoints

  /// Get all content with optional filtering and pagination
  Future<List<Content>> getContent({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/content',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Content.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to get content: $e');
    }
  }

  /// Create content
  Future<Content> createContent(Content content) async {
    try {
      final response = await _dio.post('/content', data: content.toJson());
      return Content.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to create content: $e');
    }
  }

  /// Get content by ID
  Future<Content> getContentById(String id) async {
    try {
      final response = await _dio.get('/content/$id');
      return Content.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to get content: $e');
    }
  }

  /// Update content
  Future<Content> updateContent(String id, Content content) async {
    try {
      final response = await _dio.put('/content/$id', data: content.toJson());
      return Content.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to update content: $e');
    }
  }

  /// Delete content
  Future<void> deleteContent(String id) async {
    try {
      await _dio.delete('/content/$id');
    } catch (e) {
      throw ApiException('Failed to delete content: $e');
    }
  }

  /// Upload file content
  Future<Content> uploadContent(
    String filePath,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'metadata': metadata,
      });
      
      final response = await _dio.post('/content/upload', data: formData);
      return Content.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to upload content: $e');
    }
  }

  // Contact endpoints

  /// Get all contacts with optional filtering and pagination
  Future<List<Contact>> getContacts({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/contact',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Contact.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to get contacts: $e');
    }
  }

  /// Create a new contact
  Future<Contact> createContact(Contact contact) async {
    try {
      final response = await _dio.post('/contact', data: contact.toJson());
      return Contact.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to create contact: $e');
    }
  }

  /// Get contact by ID
  Future<Contact> getContact(String id) async {
    try {
      final response = await _dio.get('/contact/$id');
      return Contact.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to get contact: $e');
    }
  }

  /// Update a contact
  Future<Contact> updateContact(String id, Contact contact) async {
    try {
      final response = await _dio.put('/contact/$id', data: contact.toJson());
      return Contact.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to update contact: $e');
    }
  }

  /// Delete a contact
  Future<void> deleteContact(String id) async {
    try {
      await _dio.delete('/contact/$id');
    } catch (e) {
      throw ApiException('Failed to delete contact: $e');
    }
  }

  // Things endpoints

  /// Get all things with optional filtering and pagination
  Future<List<Thing>> getThings({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/things',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Thing.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to get things: $e');
    }
  }

  /// Create a new thing
  Future<Thing> createThing(Thing thing) async {
    try {
      final response = await _dio.post('/things', data: thing.toJson());
      return Thing.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to create thing: $e');
    }
  }

  /// Get thing by ID
  Future<Thing> getThing(String id) async {
    try {
      final response = await _dio.get('/things/$id');
      return Thing.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to get thing: $e');
    }
  }

  /// Update a thing
  Future<Thing> updateThing(String id, Thing thing) async {
    try {
      final response = await _dio.put('/things/$id', data: thing.toJson());
      return Thing.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Failed to update thing: $e');
    }
  }

  /// Delete a thing
  Future<void> deleteThing(String id) async {
    try {
      await _dio.delete('/things/$id');
    } catch (e) {
      throw ApiException('Failed to delete thing: $e');
    }
  }
}

/// Exception thrown by the API client
class ApiException implements Exception {
  /// Creates an [ApiException] with a message.
  const ApiException(this.message);

  /// The exception message
  final String message;

  @override
  String toString() => 'ApiException: $message';
  
  
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
    String? ciServerBaseUrl,
    Dio? httpClient,
  })  : _ciServerBaseUrl = ciServerBaseUrl ?? 'https://api.companion-intelligence.com',
        _dio = httpClient ?? Dio();

  final String _ciServerBaseUrl;
  final Dio _dio;

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
