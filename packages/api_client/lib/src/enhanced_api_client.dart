import 'package:api_client/src/caching_service.dart';
import 'package:api_client/src/database/database.dart';
import 'package:api_client/src/models/models.dart';
import 'package:api_client/src/notification_service.dart';
import 'package:dio/dio.dart';

/// {@template enhanced_api_client}
/// Enhanced API Client with SQLite caching for CI-Server integration.
/// {@endtemplate}
class EnhancedApiClient {
  /// {@macro enhanced_api_client}
  EnhancedApiClient({
    String? ciServerBaseUrl,
    Dio? httpClient,
    CachingService? cachingService,
  })  : _ciServerBaseUrl = ciServerBaseUrl ?? 'https://api.companion-intelligence.com',
        _dio = httpClient ?? Dio(),
        _cachingService = cachingService ?? CachingService() {
    _dio.options.baseUrl = _ciServerBaseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  final String _ciServerBaseUrl;
  final Dio _dio;
  final CachingService _cachingService;

  /// Get CI-Server base URL
  String get ciServerBaseUrl => _ciServerBaseUrl;

  /// Get caching service
  CachingService get caching => _cachingService;

  /// Creates a notification service instance
  NotificationService createNotificationService() {
    return NotificationService(
      baseUrl: _ciServerBaseUrl,
      dio: _dio,
    );
  }

  /// Generate a unique ID
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Initialize database and perform setup
  Future<void> initialize() async {
    // Initialize database
    await DatabaseProvider.instance.database;
    
    // Perform cache maintenance
    await _cachingService.performMaintenance();
  }

  // People endpoints with caching

  /// Get all people with caching
  Future<List<Person>> getPeople({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    bool forceRefresh = false,
  }) async {
    const endpoint = 'people';
    
    return _cachingService.cachedListApiCall<Person>(
      endpoint: endpoint,
      apiCall: () => _fetchPeopleFromApi(page: page, limit: limit, filters: filters),
      fromJson: Person.fromJson,
      toJson: (person) => person.toJson(),
      forceRefresh: forceRefresh,
    );
  }

  /// Create a new person
  Future<Person> createPerson(Person person) async {
    try {
      final response = await _dio.post('/people', data: person.toJson());
      final createdPerson = Person.fromJson(response.data as Map<String, dynamic>);
      
      // Cache the new person
      await _cachingService.cachePeople([createdPerson]);
      
      // Invalidate people list cache
      await _cachingService.invalidateCache('people');
      
      return createdPerson;
    } catch (e) {
      throw ApiException('Failed to create person: $e');
    }
  }

  /// Update a person
  Future<Person> updatePerson(String id, Person person) async {
    try {
      final response = await _dio.put('/people/$id', data: person.toJson());
      final updatedPerson = Person.fromJson(response.data as Map<String, dynamic>);
      
      // Update cache
      await _cachingService.cachePeople([updatedPerson]);
      
      // Invalidate related caches
      await _cachingService.invalidateCache('people');
      
      return updatedPerson;
    } catch (e) {
      throw ApiException('Failed to update person: $e');
    }
  }

  // Contacts endpoints with caching

  /// Get all contacts with caching
  Future<List<Contact>> getContacts({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    bool forceRefresh = false,
  }) async {
    const endpoint = 'contacts';
    
    return _cachingService.cachedListApiCall<Contact>(
      endpoint: endpoint,
      apiCall: () => _fetchContactsFromApi(page: page, limit: limit, filters: filters),
      fromJson: Contact.fromJson,
      toJson: (contact) => contact.toJson(),
      forceRefresh: forceRefresh,
    );
  }

  /// Create a new contact
  Future<Contact> createContact(Contact contact) async {
    try {
      final response = await _dio.post('/contacts', data: contact.toJson());
      final createdContact = Contact.fromJson(response.data as Map<String, dynamic>);
      
      // Cache the new contact
      await _cachingService.cacheContacts([createdContact]);
      
      // Invalidate contacts list cache
      await _cachingService.invalidateCache('contacts');
      
      return createdContact;
    } catch (e) {
      throw ApiException('Failed to create contact: $e');
    }
  }

  // Content endpoints with caching

  /// Get all content with caching
  Future<List<Content>> getContent({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
    bool forceRefresh = false,
  }) async {
    const endpoint = 'content';
    
    return _cachingService.cachedListApiCall<Content>(
      endpoint: endpoint,
      apiCall: () => _fetchContentFromApi(page: page, limit: limit, filters: filters),
      fromJson: Content.fromJson,
      toJson: (content) => content.toJson(),
      forceRefresh: forceRefresh,
    );
  }

  /// Upload content file
  Future<Content> uploadContent(String filePath, Map<String, dynamic> metadata) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'metadata': metadata,
      });

      final response = await _dio.post('/content/upload', data: formData);
      final uploadedContent = Content.fromJson(response.data as Map<String, dynamic>);
      
      // Cache the uploaded content
      await _cachingService.cacheContent([uploadedContent]);
      
      // Record file sync success
      await _cachingService.updateFileSyncStatus(
        metadata['syncId'] as String? ?? generateId(),
        FileSyncStatus.synced,
      );
      
      // Invalidate content list cache
      await _cachingService.invalidateCache('content');
      
      return uploadedContent;
    } catch (e) {
      // Record file sync failure
      if (metadata['syncId'] != null) {
        await _cachingService.updateFileSyncStatus(
          metadata['syncId'] as String,
          FileSyncStatus.failed,
          errorMessage: e.toString(),
        );
      }
      throw ApiException('Failed to upload content: $e');
    }
  }

  // Offline/caching methods

  /// Get cached people (for offline access)
  Future<List<Person>> getCachedPeople() async {
    return _cachingService.getCachedPeople();
  }

  /// Get cached contacts (for offline access)
  Future<List<Contact>> getCachedContacts() async {
    return _cachingService.getCachedContacts();
  }

  /// Get cached content (for offline access)
  Future<List<Content>> getCachedContent() async {
    return _cachingService.getCachedContent();
  }

  /// Record file for sync
  Future<void> recordFileForSync(
    String filePath,
    String fileName, {
    int? fileSize,
    String? fileType,
    String? mimeType,
    DateTime? lastModified,
  }) async {
    await _cachingService.recordFileForSync(
      filePath,
      fileName,
      fileSize: fileSize,
      fileType: fileType,
      mimeType: mimeType,
      lastModified: lastModified,
    );
  }

  /// Get files that need sync
  Future<List<FileSyncRecord>> getFilesToSync() async {
    return _cachingService.getFilesToSync();
  }

  /// Store notification
  Future<void> storeNotification(String title, {
    String? body,
    String? type,
    String? data,
  }) async {
    final notification = NotificationRecord(
      id: generateId(),
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
    
    await _cachingService.storeNotification(notification);
  }

  /// Get unread notifications
  Future<List<NotificationRecord>> getUnreadNotifications() async {
    return _cachingService.getUnreadNotifications();
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _cachingService.markNotificationAsRead(notificationId);
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return _cachingService.getCacheStats();
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _cachingService.clearAllCache();
  }

  /// Close database connections
  Future<void> close() async {
    await DatabaseProvider.instance.close();
  }

  // Private helper methods

  Future<List<Person>> _fetchPeopleFromApi({
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

      final data = response.data as List<dynamic>;
      return data.map((item) => Person.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch people: $e');
    }
  }

  Future<List<Contact>> _fetchContactsFromApi({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/contacts',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
          if (filters != null) ...filters,
        },
      );

      final data = response.data as List<dynamic>;
      return data.map((item) => Contact.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch contacts: $e');
    }
  }

  Future<List<Content>> _fetchContentFromApi({
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

      final data = response.data as List<dynamic>;
      return data.map((item) => Content.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch content: $e');
    }
  }
}

/// Exception thrown by API operations
class ApiException implements Exception {
  /// Creates an [ApiException].
  const ApiException(this.message);

  /// Error message
  final String message;

  @override
  String toString() => 'ApiException: $message';
}