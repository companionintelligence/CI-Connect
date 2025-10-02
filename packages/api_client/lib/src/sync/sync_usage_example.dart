/// {@template sync_usage_example}
/// Comprehensive example demonstrating SQLite caching, difference mapping, and sync functionality.
/// {@endtemplate}
library;

import 'package:api_client/api_client.dart';
// import 'package:app_core/app_core.dart' as api_client;

/// {@template sync_usage_example}
/// Example demonstrating the complete sync workflow.
/// {@endtemplate}
class SyncUsageExample {
  /// {@macro sync_usage_example}
  SyncUsageExample();

  late EnhancedSyncClient _syncClient;
  late EnhancedApiClient _apiClient;
  // late api_client.EnhancedFileSyncService _fileSyncService; // Requires app_core package

  /// Initializes the sync system
  Future<void> initialize() async {
    // Initialize enhanced API client with SQLite caching
    _apiClient = EnhancedApiClient(
      ciServerBaseUrl: 'https://api.companion-intelligence.com',
    );

    // Initialize enhanced sync client for sync operations
    _syncClient = EnhancedSyncClient(
      baseUrl: 'https://api.companion-intelligence.com',
    );

    await _syncClient.initialize();

    // Initialize file sync service (requires app_core package)
    // _fileSyncService = api_client.EnhancedFileSyncService(
    //   apiClient: _apiClient,
    // );
  }

  /// Demonstrates basic data operations with automatic caching
  Future<void> demonstrateBasicOperations() async {
    print('=== Basic Data Operations with Caching ===');

    // Create a new person (will be cached locally)
    const person = Person(
      id: '',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+1234567890',
    );

    final createdPerson = await _apiClient.createPerson(person);
    print('Created person: ${createdPerson.name} (ID: ${createdPerson.id})');

    // Fetch people (will use cache if available)
    final people = await _apiClient.getPeople();
    print('Fetched ${people.length} people from cache/server');

    // Update person (will mark as dirty for sync)
    final updatedPerson = createdPerson.copyWith(
      name: 'John Smith',
    );
    await _apiClient.updatePerson(createdPerson.id, updatedPerson);
    print('Updated person: ${updatedPerson.name}');

    // Fetch places with caching
    final contacts = await _apiClient.getContacts();
    print('Fetched ${contacts.length} contacts from cache/server');
  }

  /// Demonstrates difference mapping and sync operations
  Future<void> demonstrateSyncOperations() async {
    print('\n=== Sync Operations and Difference Mapping ===');

    // Get sync statistics before sync
    final statsBefore = await _syncClient.getSyncStats();
    print('Sync stats before:');
    for (final entry in statsBefore.entries) {
      final entityType = entry.key;
      final data = entry.value as Map<String, dynamic>;
      print('  $entityType: ${data['total']} total, ${data['dirty']} dirty');
    }

    // Perform full sync of all dirty records
    print('\nPerforming full sync...');
    final syncResult = await _syncClient.performFullSync();

    print('Sync completed:');
    print('  Success: ${syncResult.success}');
    print('  Synced: ${syncResult.syncedCount}');
    print('  Failed: ${syncResult.failedCount}');
    print('  Conflicts: ${syncResult.conflictCount}');

    if (syncResult.errors.isNotEmpty) {
      print('  Errors:');
      for (final error in syncResult.errors) {
        print('    - $error');
      }
    }

    if (syncResult.conflicts.isNotEmpty) {
      print('  Conflicts:');
      for (final conflict in syncResult.conflicts) {
        print(
          '    - ${conflict.entityType}/${conflict.entityId}: ${conflict.conflictType}',
        );
      }
    }

    // Get sync statistics after sync
    final statsAfter = await _syncClient.getSyncStats();
    print('\nSync stats after:');
    for (final entry in statsAfter.entries) {
      final entityType = entry.key;
      final data = entry.value as Map<String, dynamic>;
      print('  $entityType: ${data['total']} total, ${data['dirty']} dirty');
    }
  }

  /// Demonstrates conflict resolution
  Future<void> demonstrateConflictResolution() async {
    print('\n=== Conflict Resolution ===');

    // Simulate a conflict by creating conflicting data
    const person = Person(
      id: 'conflict-test',
      name: 'Conflict Person',
      email: 'conflict@example.com',
      phone: '+1111111111',
    );

    // Create locally (will be dirty)
    await _apiClient.createPerson(person);
    print('Created person locally: ${person.name}');

    // Simulate server having different data
    // In real scenario, this would happen when server has newer data
    print('Simulating server conflict...');

    // Try to sync (will detect conflict)
    final syncResult = await _syncClient.performFullSync();

    if (syncResult.conflicts.isNotEmpty) {
      final conflict = syncResult.conflicts.first;
      print('Detected conflict: ${conflict.conflictType}');

      // Resolve conflict by choosing local version
      final resolved = await _syncClient.resolveConflict(conflict, true);
      print('Conflict resolved using local version: $resolved');
    }
  }

  /// Demonstrates file synchronization with difference tracking
  Future<void> demonstrateFileSync() async {
    print('\n=== File Synchronization ===');

    // Discover files for sync
    // File discovery (requires app_core package)
    // final recordedCount = await _fileSyncService.discoverAndRecordFiles([
    //   api_client.FileType.image,
    //   api_client.FileType.video,
    //   api_client.FileType.document,
    // ]);
    print('File discovery would be performed here with app_core package');

    // Sync files with progress tracking (requires app_core package)
    // final result = await _fileSyncService.syncPendingFiles(
    //   onProgress: (int current, int total, String fileName) {
    //     print('Syncing $current/$total: $fileName');
    //   },
    // );

    print('File sync would be completed here with app_core package');

    // Retry failed syncs (requires app_core package)
    // if (result.failedFiles > 0) {
    //   print('\nRetrying failed syncs...');
    //   await _fileSyncService.retryFailedSyncs();
    // }
  }

  /// Demonstrates offline-first functionality
  Future<void> demonstrateOfflineFunctionality() async {
    print('\n=== Offline-First Functionality ===');

    // Simulate offline scenario by creating data locally
    const offlinePerson = Person(
      id: '',
      name: 'Offline Person',
      email: 'offline@example.com',
      phone: '+9999999999',
    );

    // Create locally (will be marked as dirty)
    await _apiClient.createPerson(offlinePerson);
    print('Created person offline: ${offlinePerson.name}');

    // Fetch data (will use cache since we're "offline")
    final cachedPeople = await _apiClient.getPeople();
    print('Fetched ${cachedPeople.length} people from cache (offline)');

    // Simulate coming back online and syncing
    print('Coming back online...');
    final syncResult = await _syncClient.performFullSync();
    print('Offline changes synced: ${syncResult.syncedCount} records');
  }

  /// Demonstrates cache management
  Future<void> demonstrateCacheManagement() async {
    print('\n=== Cache Management ===');

    // Get cache statistics
    final stats = await _syncClient.getSyncStats();
    print('Current cache statistics:');
    for (final entry in stats.entries) {
      final entityType = entry.key;
      final data = entry.value as Map<String, dynamic>;
      print('  $entityType: ${data['total']} total, ${data['dirty']} dirty');
    }

    // Force refresh from server
    print('\nForce refreshing data from server...');
    final freshPeople = await _apiClient.getPeople(forceRefresh: true);
    print('Fetched ${freshPeople.length} fresh people from server');

    // Mark all as dirty for full resync
    print('\nMarking all records as dirty for full resync...');
    await _syncClient.markAllAsDirty();

    final statsAfterMark = await _syncClient.getSyncStats();
    print('After marking as dirty:');
    for (final entry in statsAfterMark.entries) {
      final entityType = entry.key;
      final data = entry.value as Map<String, dynamic>;
      print('  $entityType: ${data['total']} total, ${data['dirty']} dirty');
    }
  }

  /// Demonstrates batch operations
  Future<void> demonstrateBatchOperations() async {
    print('\n=== Batch Operations ===');

    // Create multiple people in batch
    final people = [
      const Person(id: '', name: 'Batch Person 1', email: 'batch1@example.com'),
      const Person(id: '', name: 'Batch Person 2', email: 'batch2@example.com'),
      const Person(id: '', name: 'Batch Person 3', email: 'batch3@example.com'),
    ];

    print('Creating ${people.length} people in batch...');
    for (final person in people) {
      await _apiClient.createPerson(person);
    }

    // Sync all batch changes
    final syncResult = await _syncClient.performFullSync();
    print('Batch sync completed: ${syncResult.syncedCount} records synced');
  }

  /// Runs the complete demonstration
  Future<void> runCompleteDemo() async {
    try {
      await initialize();

      await demonstrateBasicOperations();
      await demonstrateSyncOperations();
      await demonstrateConflictResolution();
      await demonstrateFileSync();
      await demonstrateOfflineFunctionality();
      await demonstrateCacheManagement();
      await demonstrateBatchOperations();

      print('\n=== Demo Completed Successfully ===');
    } catch (e) {
      print('Demo failed with error: $e');
    } finally {
      await _syncClient.close();
    }
  }
}

/// Main function to run the sync usage example
Future<void> main() async {
  final example = SyncUsageExample();
  await example.runCompleteDemo();
}
