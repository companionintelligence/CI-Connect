import 'package:api_client/api_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('ApiClient', () {
    late MockFirebaseFirestore mockFirestore;
    late ApiClient apiClient;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      apiClient = ApiClient(firestore: mockFirestore);
    });

    test('creates instance with calendar sync service', () {
      expect(apiClient.calendarSync, isA<CalendarSyncService>());
    });

    test('generates ID using Firestore', () {
      // Arrange
      when(() => mockFirestore.generateId()).thenReturn('generated-id');

      // Act
      final id = apiClient.generateId();

      // Assert
      expect(id, 'generated-id');
      verify(() => mockFirestore.generateId()).called(1);
    });

    test('provides access to calendar sync functionality', () {
      // The calendar sync service should be accessible through the API client
      expect(apiClient.calendarSync, isNotNull);
      expect(apiClient.calendarSync, isA<CalendarSyncService>());
    });
  });
}