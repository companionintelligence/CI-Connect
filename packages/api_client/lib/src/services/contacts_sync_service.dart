import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_extensions.dart';
import '../models/models.dart';

/// {@template contacts_sync_service}
/// Service for syncing contact health data with CI-Server API
/// {@endtemplate}
class ContactsSyncService {
  /// {@macro contacts_sync_service}
  ContactsSyncService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

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
      // Store sync data in Firestore
      await _storeContactSyncData(syncData);

      // Sync health data entries to CI-Server
      await _syncHealthDataEntries(studioId, contactId, healthData);

      // Update sync status to completed
      final completedSyncData = syncData.copyWith(
        syncStatus: ContactSyncStatus.completed,
        lastSyncTime: DateTime.now(),
      );

      await _storeContactSyncData(completedSyncData);
      return completedSyncData;
    } catch (e) {
      // Update sync status to failed
      final failedSyncData = syncData.copyWith(
        syncStatus: ContactSyncStatus.failed,
        errorMessage: e.toString(),
        retryCount: syncData.retryCount + 1,
      );

      await _storeContactSyncData(failedSyncData);
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
      final contactsSnapshot = await _firestore
          .contactsCollection(studioId: studioId)
          .get();

      for (final contactDoc in contactsSnapshot.docs) {
        try {
          // Get health data for this contact
          final healthData = await _getContactHealthData(
            studioId: studioId,
            contactId: contactDoc.id,
          );

          if (healthData.isNotEmpty) {
            final syncResult = await syncContactHealthData(
              studioId: studioId,
              contactId: contactDoc.id,
              healthData: healthData,
            );
            results.add(syncResult);
          }
        } catch (e) {
          // Continue with other contacts even if one fails
          final failedSyncData = ContactSyncData(
            contactId: contactDoc.id,
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
      final existingSyncData = await _getContactSyncData(
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
    return await _getContactSyncData(
      studioId: studioId,
      contactId: contactId,
    );
  }

  /// Gets sync status for all contacts in a studio
  Future<List<ContactSyncData>> getAllContactsSyncStatus({
    required String studioId,
  }) async {
    try {
      final syncDataSnapshot = await _firestore
          .studioDoc(studioId)
          .collection('contact_sync_data')
          .get();

      return syncDataSnapshot.docs
          .map((doc) => ContactSyncData.fromJson({
                ...doc.data(),
                'contactId': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ContactSyncException('Failed to get contacts sync status: $e');
    }
  }

  // Private helper methods

  Future<void> _storeContactSyncData(ContactSyncData syncData) async {
    await _firestore
        .studioDoc(syncData.studioId)
        .collection('contact_sync_data')
        .doc(syncData.contactId)
        .set(syncData.toJson());
  }

  Future<ContactSyncData?> _getContactSyncData({
    required String studioId,
    required String contactId,
  }) async {
    final doc = await _firestore
        .studioDoc(studioId)
        .collection('contact_sync_data')
        .doc(contactId)
        .get();

    if (!doc.exists) return null;

    return ContactSyncData.fromJson({
      ...doc.data()!,
      'contactId': contactId,
    });
  }

  Future<List<HealthData>> _getContactHealthData({
    required String studioId,
    required String contactId,
  }) async {
    final healthDataSnapshot = await _firestore
        .contactDoc(studioId: studioId, contactId: contactId)
        .collection('health_data')
        .orderBy('timestamp', descending: true)
        .get();

    return healthDataSnapshot.docs
        .map((doc) => HealthData.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }

  Future<void> _syncHealthDataEntries(
    String studioId,
    String contactId,
    List<HealthData> healthData,
  ) async {
    // Store each health data entry in the CI-Server (Firestore)
    final batch = _firestore.batch();

    for (final data in healthData) {
      final healthDataRef = _firestore
          .contactDoc(studioId: studioId, contactId: contactId)
          .collection('health_data')
          .doc(data.id);

      batch.set(healthDataRef, data.toJson());
    }

    await batch.commit();
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