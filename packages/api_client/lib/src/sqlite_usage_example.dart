/// Example demonstrating SQLite-based local storage and API caching
/// for the CI-Connect application.
library;

import 'package:api_client/api_client.dart';
// import 'package:app_core/app_core.dart';

/// Example class showing how to use the SQLite-enhanced API client
class SqliteUsageExample {
  /// Enhanced API client with SQLite caching
  late final EnhancedApiClient _apiClient;

  // Note: File sync service is in app_core package, not api_client

  /// Initialize the SQLite-enhanced services
  Future<void> initialize() async {
    // Create enhanced API client with caching
    _apiClient = EnhancedApiClient(
      ciServerBaseUrl: 'https://your-ci-server.com/api',
    );

    // Initialize database and perform setup
    await _apiClient.initialize();

    // Note: File sync service would be initialized here if using app_core package

    print('✅ SQLite database and caching services initialized');
  }

  /// Example: Working with cached people data
  Future<void> examplePeopleOperations() async {
    print('\n📋 People Operations with SQLite Caching');

    // Fetch people from API (with automatic caching)
    final people = await _apiClient.getPeople(limit: 10);
    print('Fetched ${people.length} people from API (cached locally)');

    // Get cached people (works offline)
    final cachedPeople = await _apiClient.getCachedPeople();
    print('Retrieved ${cachedPeople.length} people from local cache');

    // Create a new person
    final newPerson = Person(
      id: _apiClient.generateId(),
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
      createdAt: DateTime.now(),
    );

    try {
      final createdPerson = await _apiClient.createPerson(newPerson);
      print('✅ Created person: ${createdPerson.name}');
    } catch (e) {
      print('❌ Failed to create person: $e');
      // Person is still cached locally for offline access
    }

    // Search cached people (works offline)
    final dao = PeopleDao();
    final searchResults = await dao.search('John');
    print('Found ${searchResults.length} people matching "John"');
  }

  /// Example: Working with contacts and local sync
  Future<void> exampleContactsOperations() async {
    print('\n📞 Contacts Operations with SQLite');

    // Fetch and cache contacts
    final contacts = await _apiClient.getContacts(forceRefresh: true);
    print('Fetched and cached ${contacts.length} contacts');

    // Work with cached contacts offline
    final cachedContacts = await _apiClient.getCachedContacts();
    print('Local cache contains ${cachedContacts.length} contacts');

    // Create new contact
    final newContact = Contact(
      id: _apiClient.generateId(),
      name: 'Jane Smith',
      email: 'jane.smith@company.com',
      company: 'Acme Corp',
      notes: 'Met at conference',
      createdAt: DateTime.now(),
    );

    try {
      await _apiClient.createContact(newContact);
      print('✅ Created contact: ${newContact.name}');
    } catch (e) {
      print('❌ Failed to create contact, cached locally for sync: $e');
    }
  }

  /// Example: File synchronization with SQLite tracking
  Future<void> exampleFileSyncOperations() async {
    print('\n📁 File Sync Operations with SQLite Tracking');

    // Request permissions (requires app_core package)
    // final hasPermissions = await _fileSyncService.requestPermissions();
    // if (!hasPermissions) {
    //   print('❌ Storage permissions not granted');
    //   return;
    // }

    // Note: File discovery would be done here if using app_core package
    print('📋 File discovery would be performed here with app_core package');

    // Get sync statistics (requires app_core package)
    // final stats = await _fileSyncService.getSyncStats();
    print('📊 Sync Stats would be displayed here with app_core package');

    // Sync pending files (requires app_core package)
    try {
      // final result = await _fileSyncService.syncPendingFiles(
      //   onProgress: (current, total, fileName) {
      //     print('📤 Syncing $current/$total: $fileName');
      //   },
      // );

      print('✅ Sync would be completed here with app_core package');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }

  /// Example: Notification management with SQLite
  Future<void> exampleNotificationOperations() async {
    print('\n🔔 Notification Operations with SQLite');

    // Store notifications locally
    await _apiClient.storeNotification(
      'Sync Complete',
      body: 'All files have been successfully synced to CI-Server',
      type: 'success',
    );

    await _apiClient.storeNotification(
      'New Contact Added',
      body: 'Jane Smith has been added to your contacts',
      type: 'info',
    );

    // Get unread notifications
    final unreadNotifications = await _apiClient.getUnreadNotifications();
    print('📬 Unread notifications: ${unreadNotifications.length}');

    for (final notification in unreadNotifications) {
      print('  - ${notification.title}: ${notification.body}');
    }

    // Mark notifications as read
    for (final notification in unreadNotifications) {
      await _apiClient.markNotificationAsRead(notification.id);
    }

    print('✅ All notifications marked as read');
  }

  /// Example: API response caching
  Future<void> exampleApiCaching() async {
    print('\n💾 API Response Caching');

    // Make API calls that will be cached
    print('📡 Making API calls (will be cached)...');

    final people = await _apiClient.getPeople(limit: 5);
    final contacts = await _apiClient.getContacts(limit: 5);
    final content = await _apiClient.getContent(limit: 5);

    print('✅ API calls completed and cached');

    // Get cache statistics
    final cacheStats = await _apiClient.getCacheStats();
    print('📊 Cache Statistics:');
    print('  - Cache entries: ${cacheStats['cache']['total_entries']}');
    print('  - Valid entries: ${cacheStats['cache']['valid_entries']}');
    print('  - Cache hit rate: ${cacheStats['cache']['hit_rate']}%');
    print('  - Unread notifications: ${cacheStats['unread_notifications']}');

    // Demonstrate offline access
    print('\n🔌 Simulating offline access...');

    // These calls will return cached data
    final cachedPeople = await _apiClient.getCachedPeople();
    final cachedContacts = await _apiClient.getCachedContacts();
    final cachedContent = await _apiClient.getCachedContent();

    print('📱 Offline data access:');
    print('  - People: ${cachedPeople.length}');
    print('  - Contacts: ${cachedContacts.length}');
    print('  - Content: ${cachedContent.length}');
  }

  /// Example: Database maintenance operations
  Future<void> exampleMaintenanceOperations() async {
    print('\n🧹 Database Maintenance Operations');

    // Perform cache maintenance
    await _apiClient.caching.performMaintenance();
    print('✅ Cache maintenance completed');

    // Clean up old file sync records (requires app_core package)
    // final removedRecords = await _fileSyncService.cleanupOldRecords(
    //   olderThan: const Duration(days: 30),
    // );
    print('🗑️  Cleanup would be performed here with app_core package');

    // Retry failed syncs (requires app_core package)
    // final retriedCount = await _fileSyncService.retryFailedSyncs();
    print('🔄 Retry would be performed here with app_core package');

    // Get final statistics
    final finalStats = await _apiClient.getCacheStats();
    print(
      '📊 Final cache size: ${finalStats['cache']['cache_size_bytes']} bytes',
    );
  }

  /// Cleanup resources
  Future<void> cleanup() async {
    print('\n🧹 Cleaning up resources...');
    await _apiClient.close();
    print('✅ Resources cleaned up');
  }

  /// Run the complete example
  static Future<void> runExample() async {
    final example = SqliteUsageExample();

    try {
      await example.initialize();

      await example.examplePeopleOperations();
      await example.exampleContactsOperations();
      await example.exampleFileSyncOperations();
      await example.exampleNotificationOperations();
      await example.exampleApiCaching();
      await example.exampleMaintenanceOperations();

      print('\n✅ SQLite integration example completed successfully!');
    } catch (e) {
      print('\n❌ Example failed: $e');
    } finally {
      await example.cleanup();
    }
  }
}

/// Entry point for the example
Future<void> main() async {
  print('🚀 Starting SQLite Integration Example for CI-Connect\n');
  await SqliteUsageExample.runExample();
}
