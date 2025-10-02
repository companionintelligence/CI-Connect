import 'dart:async';

import 'package:api_client/src/database/database.dart';
import 'package:api_client/src/models/models.dart';

/// {@template caching_service}
/// Service that provides SQLite-based caching for API responses.
/// {@endtemplate}
class CachingService {
  /// {@macro caching_service}
  CachingService({
    ApiCacheDao? cacheDao,
    PeopleDao? peopleDao,
    ContactsDao? contactsDao,
    ContentDao? contentDao,
    FileSyncDao? fileSyncDao,
    NotificationsDao? notificationsDao,
  })  : _cacheDao = cacheDao ?? ApiCacheDao(),
        _peopleDao = peopleDao ?? PeopleDao(),
        _contactsDao = contactsDao ?? ContactsDao(),
        _contentDao = contentDao ?? ContentDao(),
        _fileSyncDao = fileSyncDao ?? FileSyncDao(),
        _notificationsDao = notificationsDao ?? NotificationsDao();

  final ApiCacheDao _cacheDao;
  final PeopleDao _peopleDao;
  final ContactsDao _contactsDao;
  final ContentDao _contentDao;
  final FileSyncDao _fileSyncDao;
  final NotificationsDao _notificationsDao;

  /// Default cache TTL
  static const Duration _defaultTtl = Duration(hours: 1);

  /// Executes an API call with caching support
  Future<T> cachedApiCall<T>({
    required String endpoint,
    required Future<T> Function() apiCall,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    ttl ??= _defaultTtl;

    // Check cache first (unless forced refresh)
    if (!forceRefresh) {
      final cachedData = await _cacheDao.getCachedResponse(endpoint);
      if (cachedData != null) {
        try {
          return fromJson(cachedData);
        } catch (e) {
          // Invalid cached data, continue to API call
        }
      }
    }

    // Make API call
    final result = await apiCall();
    
    // Cache the result
    try {
      await _cacheDao.cacheResponse(endpoint, toJson(result), ttl: ttl);
    } catch (e) {
      // Cache failure shouldn't break the API call
    }

    return result;
  }

  /// Caches a list of entities
  Future<List<T>> cachedListApiCall<T>({
    required String endpoint,
    required Future<List<T>> Function() apiCall,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    ttl ??= _defaultTtl;

    // Check cache first
    if (!forceRefresh) {
      final cachedData = await _cacheDao.getCachedResponse(endpoint);
      if (cachedData != null) {
        try {
          final list = cachedData['data'] as List<dynamic>;
          return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
        } catch (e) {
          // Invalid cached data, continue to API call
        }
      }
    }

    // Make API call
    final result = await apiCall();
    
    // Cache the result
    try {
      final cacheData = {
        'data': result.map(toJson).toList(),
        'count': result.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _cacheDao.cacheResponse(endpoint, cacheData, ttl: ttl);
    } catch (e) {
      // Cache failure shouldn't break the API call
    }

    return result;
  }

  /// Caches people data
  Future<void> cachePeople(List<Person> people) async {
    final cachedPeople = people.map(CachedPerson.fromPerson).toList();
    await _peopleDao.insertBatch(cachedPeople);
  }

  /// Gets cached people
  Future<List<Person>> getCachedPeople() async {
    final cached = await _peopleDao.getAll(orderBy: 'name ASC');
    return cached.map((c) => c.toPerson()).toList();
  }

  /// Caches contacts data
  Future<void> cacheContacts(List<Contact> contacts) async {
    final cachedContacts = contacts.map(CachedContact.fromContact).toList();
    await _contactsDao.insertBatch(cachedContacts);
  }

  /// Gets cached contacts
  Future<List<Contact>> getCachedContacts() async {
    final cached = await _contactsDao.getAll(orderBy: 'name ASC');
    return cached.map((c) => c.toContact()).toList();
  }

  /// Caches content data
  Future<void> cacheContent(List<Content> content) async {
    final cachedContent = content.map(CachedContent.fromContent).toList();
    await _contentDao.insertBatch(cachedContent);
  }

  /// Gets cached content
  Future<List<Content>> getCachedContent() async {
    final cached = await _contentDao.getAll(orderBy: 'created_at DESC');
    return cached.map((c) => c.toContent()).toList();
  }

  /// Records file for sync tracking
  Future<void> recordFileForSync(
    String filePath,
    String fileName, {
    int? fileSize,
    String? fileType,
    String? mimeType,
    DateTime? lastModified,
  }) async {
    final record = FileSyncRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      mimeType: mimeType,
      lastModified: lastModified,
    );

    await _fileSyncDao.insert(record);
  }

  /// Gets files that need sync
  Future<List<FileSyncRecord>> getFilesToSync() async {
    return _fileSyncDao.getFilesToSync();
  }

  /// Updates file sync status
  Future<void> updateFileSyncStatus(
    String fileId,
    FileSyncStatus status, {
    String? errorMessage,
  }) async {
    await _fileSyncDao.updateSyncStatus(fileId, status, errorMessage: errorMessage);
  }

  /// Stores notification
  Future<void> storeNotification(NotificationRecord notification) async {
    await _notificationsDao.insert(notification);
  }

  /// Gets unread notifications
  Future<List<NotificationRecord>> getUnreadNotifications() async {
    return _notificationsDao.getUnread();
  }

  /// Marks notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsDao.markAsRead(notificationId);
  }

  /// Performs cache maintenance
  Future<void> performMaintenance() async {
    // Remove expired cache entries
    await _cacheDao.removeExpiredEntries();
    
    // Optimize cache
    await _cacheDao.optimizeCache();
    
    // Clean up old file sync records
    await _fileSyncDao.removeOldRecords();
  }

  /// Gets cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final cacheStats = await _cacheDao.getCacheStats();
    final fileSyncStats = await _fileSyncDao.getSyncStats();
    final unreadCount = await _notificationsDao.getUnreadCount();

    return {
      'cache': cacheStats,
      'file_sync': fileSyncStats,
      'unread_notifications': unreadCount,
    };
  }

  /// Clears all cached data
  Future<void> clearAllCache() async {
    await _cacheDao.deleteAll();
    await _peopleDao.deleteAll();
    await _contactsDao.deleteAll();
    await _contentDao.deleteAll();
  }

  /// Invalidates cache for specific endpoint pattern
  Future<void> invalidateCache(String endpointPattern) async {
    await _cacheDao.clearCacheForEndpoint(endpointPattern);
  }
}