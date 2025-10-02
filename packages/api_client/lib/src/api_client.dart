/// {@template api_client}
/// API Client for CI-Connect that integrates with CI-Server endpoints.
/// CI-Connect API Client for CI-Server integration.
/// Provides access to people, places, content, contact, and things endpoints.
/// {@endtemplate}
library;
import 'package:api_client/src/models/models.dart';
import 'package:api_client/src/services/services.dart';
import 'package:dio/dio.dart';

class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    String? ciServerBaseUrl,
    Dio? httpClient,
  }) : _ciServerBaseUrl =
           ciServerBaseUrl ?? 'https://api.companion-intelligence.com',
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

  /// Generate a unique ID (replaces Firebase document ID generation)
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

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
}
