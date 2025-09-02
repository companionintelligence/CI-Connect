import 'package:test/test.dart';
import '../lib/api_client.dart';

void main() {
  group('API Client Refactoring', () {
    test('CIServerClient can be instantiated', () {
      final dio = Dio();
      final client = CIServerClient(
        dio: dio,
        baseUrl: 'https://test.com',
        apiKey: 'test-key',
      );
      
      expect(client, isA<CIServerClient>());
    });

    test('ApiClient creates CIServerClient correctly', () {
      final apiClient = ApiClient(
        baseUrl: 'https://test.com',
        apiKey: 'test-key',
      );
      
      expect(apiClient.ciServerClient, isA<CIServerClient>());
      expect(apiClient.generateId(), isNotEmpty);
    });

    test('ContactsSyncService can be instantiated with CIServerClient', () {
      final apiClient = ApiClient(baseUrl: 'https://test.com');
      final syncService = ContactsSyncService(
        ciServerClient: apiClient.ciServerClient,
      );
      
      expect(syncService, isA<ContactsSyncService>());
    });

    test('ApiContactsSyncRepository can be instantiated', () {
      final apiClient = ApiClient(baseUrl: 'https://test.com');
      final syncService = ContactsSyncService(
        ciServerClient: apiClient.ciServerClient,
      );
      final repository = ApiContactsSyncRepository(
        contactsSyncService: syncService,
      );
      
      expect(repository, isA<ContactsSyncRepository>());
    });

    test('Models still work with JSON serialization', () {
      final healthData = HealthData(
        id: 'test_id',
        contactId: 'contact_123',
        dataType: 'heart_rate',
        value: '72',
        unit: 'bpm',
        timestamp: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );
      
      final json = healthData.toJson();
      final reconstructed = HealthData.fromJson(json);
      
      expect(reconstructed.id, equals(healthData.id));
      expect(reconstructed.contactId, equals(healthData.contactId));
      expect(reconstructed.dataType, equals(healthData.dataType));
      expect(reconstructed.value, equals(healthData.value));
      expect(reconstructed.unit, equals(healthData.unit));
      expect(reconstructed.timestamp, equals(healthData.timestamp));
    });

    test('ContactSyncData works with refactored models', () {
      final healthData = [
        HealthData(
          id: 'health_001',
          contactId: 'contact_123',
          dataType: 'heart_rate',
          value: '72',
          unit: 'bpm',
          timestamp: DateTime.parse('2024-01-01T10:00:00.000Z'),
        )
      ];

      final syncData = ContactSyncData(
        contactId: 'contact_123',
        studioId: 'studio_456',
        lastSyncTime: DateTime.parse('2024-01-01T10:00:00.000Z'),
        healthData: healthData,
        syncStatus: ContactSyncStatus.completed,
      );

      final json = syncData.toJson();
      final reconstructed = ContactSyncData.fromJson(json);

      expect(reconstructed.contactId, equals(syncData.contactId));
      expect(reconstructed.studioId, equals(syncData.studioId));
      expect(reconstructed.syncStatus, equals(syncData.syncStatus));
      expect(reconstructed.healthData.length, equals(1));
      expect(reconstructed.healthData.first.dataType, equals('heart_rate'));
    });
  });
}