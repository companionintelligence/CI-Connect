import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('ContactSyncData', () {
    test('can be created from JSON', () {
      final json = {
        'contactId': 'contact_123',
        'studioId': 'studio_456',
        'lastSyncTime': '2024-01-01T10:00:00.000Z',
        'healthData': [
          {
            'id': 'health_001',
            'contactId': 'contact_123',
            'dataType': 'heart_rate',
            'value': '72',
            'unit': 'bpm',
            'timestamp': '2024-01-01T10:00:00.000Z',
          }
        ],
        'syncStatus': 'completed',
        'errorMessage': null,
        'retryCount': 1,
      };

      final contactSyncData = ContactSyncData.fromJson(json);

      expect(contactSyncData.contactId, equals('contact_123'));
      expect(contactSyncData.studioId, equals('studio_456'));
      expect(contactSyncData.healthData, hasLength(1));
      expect(contactSyncData.syncStatus, equals(ContactSyncStatus.completed));
      expect(contactSyncData.errorMessage, isNull);
      expect(contactSyncData.retryCount, equals(1));
    });

    test('can be converted to JSON', () {
      final timestamp = DateTime.parse('2024-01-01T10:00:00.000Z');
      final healthData = [
        HealthData(
          id: 'health_001',
          contactId: 'contact_123',
          dataType: 'heart_rate',
          value: '72',
          unit: 'bpm',
          timestamp: timestamp,
        )
      ];

      final contactSyncData = ContactSyncData(
        contactId: 'contact_123',
        studioId: 'studio_456',
        lastSyncTime: timestamp,
        healthData: healthData,
        syncStatus: ContactSyncStatus.completed,
        errorMessage: 'Test error',
        retryCount: 2,
      );

      final json = contactSyncData.toJson();

      expect(json['contactId'], equals('contact_123'));
      expect(json['studioId'], equals('studio_456'));
      expect(json['lastSyncTime'], equals(timestamp.toIso8601String()));
      expect(json['healthData'], hasLength(1));
      expect(json['syncStatus'], equals('completed'));
      expect(json['errorMessage'], equals('Test error'));
      expect(json['retryCount'], equals(2));
    });

    test('has default values', () {
      final contactSyncData = ContactSyncData(
        contactId: 'contact_123',
        studioId: 'studio_456',
        lastSyncTime: DateTime.now(),
        healthData: const [],
      );

      expect(contactSyncData.syncStatus, equals(ContactSyncStatus.pending));
      expect(contactSyncData.errorMessage, isNull);
      expect(contactSyncData.retryCount, equals(0));
    });

    test('copyWith creates new instance with updated values', () {
      final original = ContactSyncData(
        contactId: 'contact_123',
        studioId: 'studio_456',
        lastSyncTime: DateTime.now(),
        healthData: const [],
      );

      final copy = original.copyWith(
        syncStatus: ContactSyncStatus.completed,
        retryCount: 1,
      );

      expect(copy.contactId, equals(original.contactId));
      expect(copy.syncStatus, equals(ContactSyncStatus.completed));
      expect(copy.retryCount, equals(1));
    });
  });

  group('ContactSyncStatus', () {
    test('has correct enum values', () {
      expect(ContactSyncStatus.pending.name, equals('pending'));
      expect(ContactSyncStatus.syncing.name, equals('syncing'));
      expect(ContactSyncStatus.completed.name, equals('completed'));
      expect(ContactSyncStatus.failed.name, equals('failed'));
      expect(ContactSyncStatus.cancelled.name, equals('cancelled'));
    });
  });
}