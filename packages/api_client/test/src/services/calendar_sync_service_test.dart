import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCIServerApiClient extends Mock implements CIServerApiClient {}

void main() {
  group('CalendarSyncService', () {
    late MockCIServerApiClient mockApiClient;
    late CalendarSyncService service;

    setUp(() {
      mockApiClient = MockCIServerApiClient();
      service = CalendarSyncService(apiClient: mockApiClient);
    });

    group('syncAllCalendars', () {
      test('successfully syncs all calendars and their events', () async {
        // Mock the create/update operations for calendars
        when(() => mockApiClient.update(any(), any(), any()))
            .thenThrow(const CIServerApiException('Not found'));
        when(() => mockApiClient.create(any(), any()))
            .thenAnswer((_) async => {'id': 'created-id'});

        final result = await service.syncAllCalendars(studioId: 'studio-123');

        expect(result, hasLength(2)); // Google and Outlook calendars
        expect(result[0].source, equals('google'));
        expect(result[1].source, equals('outlook'));
        expect(result[0].lastSyncedAt, isNotNull);
        expect(result[1].lastSyncedAt, isNotNull);

        // Verify calendars were created (after update failed)
        verify(() => mockApiClient.create('api/content/calendars', any())).called(2);
        // Verify events were also synced for each calendar
        verify(() => mockApiClient.create('api/content/calendar-events', any())).called(2);
      });

      test('throws CalendarSyncException on API error', () async {
        when(() => mockApiClient.update(any(), any(), any()))
            .thenThrow(const CIServerApiException('Server error'));
        when(() => mockApiClient.create(any(), any()))
            .thenThrow(const CIServerApiException('Server error'));

        expect(
          () async => await service.syncAllCalendars(studioId: 'studio-123'),
          throwsA(isA<CalendarSyncException>()),
        );
      });
    });

    group('syncCalendar', () {
      test('successfully syncs a specific calendar', () async {
        when(() => mockApiClient.update(any(), any(), any()))
            .thenThrow(const CIServerApiException('Not found'));
        when(() => mockApiClient.create(any(), any()))
            .thenAnswer((_) async => {'id': 'created-id'});

        final result = await service.syncCalendar(
          studioId: 'studio-123',
          calendarId: 'cal-123',
        );

        expect(result.id, equals('cal-123'));
        expect(result.lastSyncedAt, isNotNull);
        expect(result.updatedAt, isNotNull);

        // Verify calendar was created
        verify(() => mockApiClient.create('api/content/calendars', any())).called(1);
        // Verify events were synced
        verify(() => mockApiClient.create('api/content/calendar-events', any())).called(1);
      });

      test('throws CalendarSyncException on API error', () async {
        when(() => mockApiClient.update(any(), any(), any()))
            .thenThrow(const CIServerApiException('Server error'));
        when(() => mockApiClient.create(any(), any()))
            .thenThrow(const CIServerApiException('Server error'));

        expect(
          () async => await service.syncCalendar(
            studioId: 'studio-123',
            calendarId: 'cal-123',
          ),
          throwsA(isA<CalendarSyncException>()),
        );
      });
    });

    group('getCalendars', () {
      test('successfully retrieves calendars from API', () async {
        when(() => mockApiClient.getAll(
          'api/content/calendars',
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => [
          {
            'id': 'cal-1',
            'name': 'Calendar 1',
            'isEnabled': true,
            'source': 'google',
            'createdAt': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cal-2',
            'name': 'Calendar 2',
            'isEnabled': false,
            'source': 'outlook',
            'createdAt': '2024-01-02T00:00:00Z',
          },
        ]);

        final result = await service.getCalendars(studioId: 'studio-123');

        expect(result, hasLength(2));
        expect(result[0].id, equals('cal-1'));
        expect(result[0].name, equals('Calendar 1'));
        expect(result[0].isEnabled, isTrue);
        expect(result[1].id, equals('cal-2'));
        expect(result[1].isEnabled, isFalse);

        verify(() => mockApiClient.getAll(
          'api/content/calendars',
          queryParameters: {'studio_id': 'studio-123'},
        )).called(1);
      });

      test('throws CalendarSyncException on API error', () async {
        when(() => mockApiClient.getAll(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(const CIServerApiException('Server error'));

        expect(
          () async => await service.getCalendars(studioId: 'studio-123'),
          throwsA(isA<CalendarSyncException>()),
        );
      });
    });

    group('getCalendarEvents', () {
      test('successfully retrieves calendar events from API', () async {
        when(() => mockApiClient.getAll(
          'api/content/calendar-events',
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => [
          {
            'id': 'event-1',
            'calendarId': 'cal-123',
            'title': 'Event 1',
            'startDateTime': '2024-01-01T10:00:00Z',
            'endDateTime': '2024-01-01T11:00:00Z',
            'isAllDay': false,
          },
          {
            'id': 'event-2',
            'calendarId': 'cal-123',
            'title': 'Event 2',
            'startDateTime': '2024-01-02T14:00:00Z',
            'endDateTime': '2024-01-02T15:00:00Z',
            'isAllDay': false,
          },
        ]);

        final result = await service.getCalendarEvents(
          studioId: 'studio-123',
          calendarId: 'cal-123',
        );

        expect(result, hasLength(2));
        expect(result[0].id, equals('event-1'));
        expect(result[0].title, equals('Event 1'));
        expect(result[0].calendarId, equals('cal-123'));
        expect(result[1].id, equals('event-2'));
        expect(result[1].title, equals('Event 2'));

        verify(() => mockApiClient.getAll(
          'api/content/calendar-events',
          queryParameters: {
            'studio_id': 'studio-123',
            'calendar_id': 'cal-123',
          },
        )).called(1);
      });

      test('throws CalendarSyncException on API error', () async {
        when(() => mockApiClient.getAll(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(const CIServerApiException('Server error'));

        expect(
          () async => await service.getCalendarEvents(
            studioId: 'studio-123',
            calendarId: 'cal-123',
          ),
          throwsA(isA<CalendarSyncException>()),
        );
      });
    });

    group('_syncCalendar', () {
      test('tries update first, then creates if update fails', () async {
        // First call to update fails (not found)
        when(() => mockApiClient.update('api/content/calendars', any(), any()))
            .thenThrow(const CIServerApiException('Not found'));
        // Second call to create succeeds
        when(() => mockApiClient.create('api/content/calendars', any()))
            .thenAnswer((_) async => {'id': 'created-id'});

        await service.syncCalendar(
          studioId: 'studio-123',
          calendarId: 'cal-123',
        );

        verify(() => mockApiClient.update('api/content/calendars', 'cal-123', any()))
            .called(1);
        verify(() => mockApiClient.create('api/content/calendars', any()))
            .called(1);
      });

      test('uses update when it succeeds', () async {
        when(() => mockApiClient.update('api/content/calendars', any(), any()))
            .thenAnswer((_) async => {'id': 'updated-id'});
        when(() => mockApiClient.create('api/content/calendar-events', any()))
            .thenAnswer((_) async => {'id': 'event-id'});

        await service.syncCalendar(
          studioId: 'studio-123',
          calendarId: 'cal-123',
        );

        verify(() => mockApiClient.update('api/content/calendars', 'cal-123', any()))
            .called(1);
        verifyNever(() => mockApiClient.create('api/content/calendars', any()));
      });
    });
  });

  group('CalendarSyncException', () {
    test('toString returns formatted message', () {
      const exception = CalendarSyncException('Test error');
      expect(exception.toString(), equals('CalendarSyncException: Test error'));
    });
  });
}