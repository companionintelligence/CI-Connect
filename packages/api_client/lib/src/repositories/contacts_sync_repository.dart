import 'dart:async';

import '../models/models.dart';
import '../services/contacts_sync_service.dart';

/// {@template contacts_sync_repository}
/// Repository for managing contact sync operations
/// {@endtemplate}
abstract class ContactsSyncRepository {
  /// Syncs health data for a specific contact
  Future<ContactSyncData> syncContactHealthData({
    required String studioId,
    required String contactId,
    required List<HealthData> healthData,
  });

  /// Syncs health data for all contacts in a studio
  Future<List<ContactSyncData>> syncAllContactsHealthData({
    required String studioId,
  });

  /// Retries failed sync operations
  Future<ContactSyncData> retrySyncContactHealthData({
    required String studioId,
    required String contactId,
    int maxRetries = 3,
  });

  /// Gets sync status for a contact
  Future<ContactSyncData?> getContactSyncStatus({
    required String studioId,
    required String contactId,
  });

  /// Gets sync status for all contacts in a studio
  Future<List<ContactSyncData>> getAllContactsSyncStatus({
    required String studioId,
  });
}

/// {@template api_contacts_sync_repository}
/// API implementation of [ContactsSyncRepository]
/// {@endtemplate}
class ApiContactsSyncRepository implements ContactsSyncRepository {
  /// {@macro api_contacts_sync_repository}
  ApiContactsSyncRepository({
    required ContactsSyncService contactsSyncService,
  }) : _contactsSyncService = contactsSyncService;

  final ContactsSyncService _contactsSyncService;

  @override
  Future<ContactSyncData> syncContactHealthData({
    required String studioId,
    required String contactId,
    required List<HealthData> healthData,
  }) async {
    return await _contactsSyncService.syncContactHealthData(
      studioId: studioId,
      contactId: contactId,
      healthData: healthData,
    );
  }

  @override
  Future<List<ContactSyncData>> syncAllContactsHealthData({
    required String studioId,
  }) async {
    return await _contactsSyncService.syncAllContactsHealthData(
      studioId: studioId,
    );
  }

  @override
  Future<ContactSyncData> retrySyncContactHealthData({
    required String studioId,
    required String contactId,
    int maxRetries = 3,
  }) async {
    return await _contactsSyncService.retrySyncContactHealthData(
      studioId: studioId,
      contactId: contactId,
      maxRetries: maxRetries,
    );
  }

  @override
  Future<ContactSyncData?> getContactSyncStatus({
    required String studioId,
    required String contactId,
  }) async {
    return await _contactsSyncService.getContactSyncStatus(
      studioId: studioId,
      contactId: contactId,
    );
  }

  @override
  Future<List<ContactSyncData>> getAllContactsSyncStatus({
    required String studioId,
  }) async {
    return await _contactsSyncService.getAllContactsSyncStatus(
      studioId: studioId,
    );
  }
}