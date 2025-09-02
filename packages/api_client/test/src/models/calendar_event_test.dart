import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarEvent', () {
    group('fromJson', () {
      test('creates instance from valid JSON', () {
        final json = {
          'id': 'event1',
          'calendarId': 'cal1',
          'title': 'Test Event',
          'description': 'A test event',
          'startTime': '2023-01-01T09:00:00.000Z',
          'endTime': '2023-01-01T10:00:00.000Z',
          'isAllDay': false,
          'location': 'Test Location',
          'attendees': ['user1@example.com', 'user2@example.com'],
          'source': 'google',
          'sourceEventId': 'google123',
          'createdAt': '2023-01-01T00:00:00.000Z',
          'updatedAt': '2023-01-01T01:00:00.000Z',
        };

        final result = CalendarEvent.fromJson(json);

        expect(result.id, 'event1');
        expect(result.calendarId, 'cal1');
        expect(result.title, 'Test Event');
        expect(result.description, 'A test event');
        expect(result.startTime, DateTime.parse('2023-01-01T09:00:00.000Z'));
        expect(result.endTime, DateTime.parse('2023-01-01T10:00:00.000Z'));
        expect(result.isAllDay, false);
        expect(result.location, 'Test Location');
        expect(result.attendees, ['user1@example.com', 'user2@example.com']);
        expect(result.source, 'google');
        expect(result.sourceEventId, 'google123');
        expect(result.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
        expect(result.updatedAt, DateTime.parse('2023-01-01T01:00:00.000Z'));
      });

      test('handles optional fields correctly', () {
        final json = {
          'id': 'event1',
          'calendarId': 'cal1',
          'title': 'Test Event',
          'startTime': '2023-01-01T09:00:00.000Z',
          'endTime': '2023-01-01T10:00:00.000Z',
          'source': 'google',
          'createdAt': '2023-01-01T00:00:00.000Z',
        };

        final result = CalendarEvent.fromJson(json);

        expect(result.description, null);
        expect(result.isAllDay, false);
        expect(result.location, null);
        expect(result.attendees, isEmpty);
        expect(result.sourceEventId, null);
        expect(result.updatedAt, null);
      });

      test('handles all-day events', () {
        final json = {
          'id': 'event1',
          'calendarId': 'cal1',
          'title': 'All Day Event',
          'startTime': '2023-01-01T00:00:00.000Z',
          'endTime': '2023-01-01T23:59:59.999Z',
          'isAllDay': true,
          'source': 'google',
          'createdAt': '2023-01-01T00:00:00.000Z',
        };

        final result = CalendarEvent.fromJson(json);

        expect(result.isAllDay, true);
      });
    });

    group('toJson', () {
      test('converts to JSON correctly', () {
        final event = CalendarEvent(
          id: 'event1',
          calendarId: 'cal1',
          title: 'Test Event',
          description: 'A test event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          isAllDay: false,
          location: 'Test Location',
          attendees: const ['user1@example.com', 'user2@example.com'],
          source: 'google',
          sourceEventId: 'google123',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2023-01-01T01:00:00.000Z'),
        );

        final result = event.toJson();

        expect(result['id'], 'event1');
        expect(result['calendarId'], 'cal1');
        expect(result['title'], 'Test Event');
        expect(result['description'], 'A test event');
        expect(result['startTime'], '2023-01-01T09:00:00.000Z');
        expect(result['endTime'], '2023-01-01T10:00:00.000Z');
        expect(result['isAllDay'], false);
        expect(result['location'], 'Test Location');
        expect(result['attendees'], ['user1@example.com', 'user2@example.com']);
        expect(result['source'], 'google');
        expect(result['sourceEventId'], 'google123');
        expect(result['createdAt'], '2023-01-01T00:00:00.000Z');
        expect(result['updatedAt'], '2023-01-01T01:00:00.000Z');
      });

      test('handles null values correctly', () {
        final event = CalendarEvent(
          id: 'event1',
          calendarId: 'cal1',
          title: 'Test Event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final result = event.toJson();

        expect(result['description'], null);
        expect(result['isAllDay'], false);
        expect(result['location'], null);
        expect(result['attendees'], isEmpty);
        expect(result['sourceEventId'], null);
        expect(result['updatedAt'], null);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = CalendarEvent(
          id: 'event1',
          calendarId: 'cal1',
          title: 'Test Event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final copy = original.copyWith(
          title: 'Updated Event',
          description: 'Updated description',
        );

        expect(copy.id, original.id);
        expect(copy.calendarId, original.calendarId);
        expect(copy.title, 'Updated Event');
        expect(copy.description, 'Updated description');
        expect(copy.startTime, original.startTime);
        expect(copy.endTime, original.endTime);
        expect(copy.source, original.source);
        expect(copy.createdAt, original.createdAt);
      });
    });

    group('equality', () {
      test('returns true for identical events', () {
        final event1 = CalendarEvent(
          id: 'event1',
          calendarId: 'cal1',
          title: 'Test Event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final event2 = CalendarEvent(
          id: 'event1',
          calendarId: 'cal1',
          title: 'Test Event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        expect(event1, event2);
        expect(event1.hashCode, event2.hashCode);
      });

      test('returns false for different events', () {
        final event1 = CalendarEvent(
          id: 'event1',
          calendarId: 'cal1',
          title: 'Test Event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final event2 = CalendarEvent(
          id: 'event2',
          calendarId: 'cal1',
          title: 'Test Event',
          startTime: DateTime.parse('2023-01-01T09:00:00.000Z'),
          endTime: DateTime.parse('2023-01-01T10:00:00.000Z'),
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        expect(event1, isNot(event2));
      });
    });
  });
}