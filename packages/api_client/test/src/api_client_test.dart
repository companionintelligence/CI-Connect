import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockCIServerApiClient extends Mock implements CIServerApiClient {}
class MockCalendarSyncService extends Mock implements CalendarSyncService {}

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('can be instantiated', () {
      expect(ApiClient(), isNotNull);
    });

    test('can be instantiated with custom base URL', () {
      const customUrl = 'https://custom.ci-server.com';
      final customApiClient = ApiClient(ciServerBaseUrl: customUrl);
      
      expect(customApiClient, isNotNull);
      expect(customApiClient.ciServerBaseUrl, equals(customUrl));
    });

    test('uses default base URL when none provided', () {
      expect(apiClient.ciServerBaseUrl, equals('https://api.companion-intelligence.com'));
    });

    test('generates unique ID', () {
      final id1 = apiClient.generateId();
      final id2 = apiClient.generateId();

      expect(id1, isNotNull);
      expect(id2, isNotNull);
      expect(id1, isNot(equals(id2)));
      expect(id1, matches(r'^\d+_\d+$'));
    });

    test('provides calendar sync service', () {
      expect(apiClient.calendarSync, isA<CalendarSyncService>());
    });

    test('creates notification service', () {
      final notificationService = apiClient.createNotificationService();
      expect(notificationService, isA<NotificationService>());
    });

    test('accepts custom CI-Server base URL for services', () {
      const customUrl = 'https://custom.ci-server.com';
      final customApiClient = ApiClient(ciServerBaseUrl: customUrl);

      expect(customApiClient.calendarSync, isA<CalendarSyncService>());
      
      final notificationService = customApiClient.createNotificationService();
      expect(notificationService, isA<NotificationService>());
    });
  });
}