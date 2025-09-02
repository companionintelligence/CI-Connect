import 'dart:async';

import '../ci_server_client.dart';
import '../models/models.dart';

/// {@template contacts_sync_service}
/// Service for syncing contact health data with CI-Server API
/// {@endtemplate}
class ContactsSyncService {
  /// {@macro contacts_sync_service}
  ContactsSyncService({
    required CIServerClient ciServerClient,
  }) : _ciServerClient = ciServerClient;

  final CIServerClient _ciServerClient;

  /// Syncs health data for a specific contact
  Future<ContactSyncData> syncContactHealthData({
    required String studioId,
    required String contactId,
    required List<HealthData> healthData,
  }) async {
    final syncData = ContactSyncData(
      contactId: contactId,
      studioId: studioId,
      lastSyncTime: DateTime.now(),
      healthData: healthData,
      syncStatus: ContactSyncStatus.syncing,
    );

    try {
      // Store sync data via API
      await _ciServerClient.updateContactSyncData(
        studioId: studioId,
        syncData: syncData,
      );

      // Sync health data entries to CI-Server
      await _ciServerClient.updateContactHealthData(
        studioId: studioId,
        contactId: contactId,
        healthData: healthData,
      );

      // Update sync status to completed
      final completedSyncData = syncData.copyWith(
        syncStatus: ContactSyncStatus.completed,
        lastSyncTime: DateTime.now(),
      );

      await _ciServerClient.updateContactSyncData(
        studioId: studioId,
        syncData: completedSyncData,
      );
      return completedSyncData;
    } catch (e) {
      // Update sync status to failed
      final failedSyncData = syncData.copyWith(
        syncStatus: ContactSyncStatus.failed,
        errorMessage: e.toString(),
        retryCount: syncData.retryCount + 1,
      );

      await _ciServerClient.updateContactSyncData(
        studioId: studioId,
        syncData: failedSyncData,
      );
      throw ContactSyncException('Failed to sync contact health data: $e');
    }
  }

  /// Syncs health data for all contacts in a studio
  Future<List<ContactSyncData>> syncAllContactsHealthData({
    required String studioId,
  }) async {
    final results = <ContactSyncData>[];

    try {
      // Get all contacts for the studio
      final contacts = await _ciServerClient.getContacts(studioId: studioId);

      for (final contactData in contacts) {
        final contactId = contactData['id'] as String? ?? 
                         contactData['contactId'] as String;
        
        try {
          // Get health data for this contact
          final healthData = await _ciServerClient.getContactHealthData(
            studioId: studioId,
            contactId: contactId,
          );

          if (healthData.isNotEmpty) {
            final syncResult = await syncContactHealthData(
              studioId: studioId,
              contactId: contactId,
              healthData: healthData,
            );
            results.add(syncResult);
          }
        } catch (e) {
          // Continue with other contacts even if one fails
          final failedSyncData = ContactSyncData(
            contactId: contactId,
            studioId: studioId,
            lastSyncTime: DateTime.now(),
            healthData: const [],
            syncStatus: ContactSyncStatus.failed,
            errorMessage: e.toString(),
          );
          results.add(failedSyncData);
        }
      }

      return results;
    } catch (e) {
      throw ContactSyncException('Failed to sync all contacts health data: $e');
    }
  }

  /// Retries failed sync operations
  Future<ContactSyncData> retrySyncContactHealthData({
    required String studioId,
    required String contactId,
    int maxRetries = 3,
  }) async {
    try {
      // Get existing sync data
      final existingSyncData = await _ciServerClient.getContactSyncData(
        studioId: studioId,
        contactId: contactId,
      );

      if (existingSyncData == null) {
        throw ContactSyncException('No existing sync data found for contact');
      }

      if (existingSyncData.retryCount >= maxRetries) {
        throw ContactSyncException('Maximum retry attempts exceeded');
      }

      // Retry the sync
      return await syncContactHealthData(
        studioId: studioId,
        contactId: contactId,
        healthData: existingSyncData.healthData,
      );
    } catch (e) {
      throw ContactSyncException('Failed to retry sync: $e');
    }
  }

  /// Gets sync status for a contact
  Future<ContactSyncData?> getContactSyncStatus({
    required String studioId,
    required String contactId,
  }) async {
    return await _ciServerClient.getContactSyncData(
      studioId: studioId,
      contactId: contactId,
    );
  }

  /// Gets sync status for all contacts in a studio
  Future<List<ContactSyncData>> getAllContactsSyncStatus({
    required String studioId,
  }) async {
    try {
      return await _ciServerClient.getAllContactsSyncData(
        studioId: studioId,
      );
    } catch (e) {
      throw ContactSyncException('Failed to get contacts sync status: $e');
    }
  }
}

/// Exception thrown when contact sync operations fail
class ContactSyncException implements Exception {
  /// Creates a [ContactSyncException]
  const ContactSyncException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'ContactSyncException: $message';
}