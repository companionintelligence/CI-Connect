import 'package:api_client/api_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCIServerApiClient extends Mock implements CIServerApiClient {}
class MockCalendarSyncService extends Mock implements CalendarSyncService {}

void main() {
  group('ApiClient', () {
    late MockFirebaseFirestore mockFirestore;
    late ApiClient apiClient;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      apiClient = ApiClient(firestore: mockFirestore);
    });

    test('can be instantiated', () {
      expect(ApiClient(firestore: mockFirestore), isNotNull);
    });

    test('generates ID using Firestore', () {
      when(() => mockFirestore.generateId()).thenReturn('generated-id');

      final result = apiClient.generateId();

      expect(result, equals('generated-id'));
      verify(() => mockFirestore.generateId()).called(1);
    });

    test('provides calendar sync service', () {
      expect(apiClient.calendarSync, isA<CalendarSyncService>());
    });

    test('provides CI-Server API client', () {
      expect(apiClient.ciServerApi, isA<CIServerApiClient>());
    });

    test('can be disposed', () {
      expect(() => apiClient.dispose(), returnsNormally);
    });

    test('accepts custom CI-Server base URL', () {
      const customUrl = 'https://custom.ci-server.com';
      final customApiClient = ApiClient(
        firestore: mockFirestore,
        ciServerBaseUrl: customUrl,
      );

      expect(customApiClient, isNotNull);
      expect(customApiClient.calendarSync, isA<CalendarSyncService>());
      expect(customApiClient.ciServerApi, isA<CIServerApiClient>());
    });
  });
}