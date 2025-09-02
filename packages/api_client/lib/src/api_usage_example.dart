/// Example usage of the CI-Server API client for contacts sync
/// 
/// This replaces the Firebase-based implementation with HTTP API calls
/// to the CI-Server endpoints.

import 'package:dio/dio.dart';
import '../api_client.dart';

/// Example function showing how to set up and use the contacts sync system
Future<void> exampleUsage() async {
  // Initialize the API client with your CI-Server base URL
  final apiClient = ApiClient(
    baseUrl: 'https://your-ci-server.com/api',
    apiKey: 'your-api-key-here', // Optional
  );

  // Create the contacts sync service
  final syncService = ContactsSyncService(
    ciServerClient: apiClient.ciServerClient,
  );

  // Create the repository
  final repository = ApiContactsSyncRepository(
    contactsSyncService: syncService,
  );

  // Example: Sync individual contact health data
  final healthData = [
    HealthData(
      id: 'health_001',
      contactId: 'contact_123',
      dataType: 'heart_rate',
      value: '72',
      unit: 'bpm',
      timestamp: DateTime.now(),
    ),
    HealthData(
      id: 'health_002',
      contactId: 'contact_123',
      dataType: 'blood_pressure',
      value: '120/80',
      unit: 'mmHg',
      timestamp: DateTime.now(),
    ),
  ];

  try {
    // Sync health data for a specific contact
    final syncResult = await repository.syncContactHealthData(
      studioId: 'studio_456',
      contactId: 'contact_123',
      healthData: healthData,
    );
    
    print('Sync completed: ${syncResult.syncStatus}');

    // Check sync status
    final status = await repository.getContactSyncStatus(
      studioId: 'studio_456',
      contactId: 'contact_123',
    );
    
    if (status != null) {
      print('Current sync status: ${status.syncStatus}');
      print('Last sync time: ${status.lastSyncTime}');
    }

    // Sync all contacts in a studio
    final allSyncResults = await repository.syncAllContactsHealthData(
      studioId: 'studio_456',
    );
    
    print('Synced ${allSyncResults.length} contacts');
    
  } catch (e) {
    print('Sync failed: $e');
    
    // Retry failed sync
    try {
      await repository.retrySyncContactHealthData(
        studioId: 'studio_456',
        contactId: 'contact_123',
        maxRetries: 3,
      );
    } catch (retryError) {
      print('Retry also failed: $retryError');
    }
  }
}

/// CI-Server API Endpoints Used:
/// 
/// GET    /contact                    - Get all contacts for a studio
/// GET    /contact/{id}               - Get specific contact
/// GET    /contact/{id}/health-data   - Get health data for a contact
/// PUT    /contact/{id}/health-data   - Update health data for a contact
/// GET    /contact/{id}/sync-status   - Get sync status for a contact
/// PUT    /contact/{id}/sync-status   - Update sync status for a contact
/// GET    /contact/sync-status        - Get sync status for all contacts in a studio
///
/// All endpoints support ?studioId=<studioId> query parameter
/// 
/// Authentication: Bearer token in Authorization header (if apiKey provided)
/// Content-Type: application/json