import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarEvent', () {
    final event = CalendarEvent(
      id: 'event-123',
      calendarId: 'cal-123',
      title: 'Test Event',
      description: 'A test event',
      location: 'Conference Room A',
      startDateTime: DateTime.parse('2024-01-01T10:00:00Z'),
      endDateTime: DateTime.parse('2024-01-01T11:00:00Z'),
      attendees: [
        const CalendarAttendee(
          email: 'test@example.com',
          name: 'Test User',
          responseStatus: 'accepted',
        ),
      ],
      recurrenceRule: 'FREQ=WEEKLY',
      status: 'confirmed',
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    group('fromJson', () {
      test('creates CalendarEvent from JSON', () {
        final json = {
          'id': 'event-123',
          'calendarId': 'cal-123',
          'title': 'Test Event',
          'description': 'A test event',
          'location': 'Conference Room A',
          'startDateTime': '2024-01-01T10:00:00Z',
          'endDateTime': '2024-01-01T11:00:00Z',
          'isAllDay': false,
          'attendees': [
            {
              'email': 'test@example.com',
              'name': 'Test User',
              'responseStatus': 'accepted',
              'isOptional': false,
            },
          ],
          'recurrenceRule': 'FREQ=WEEKLY',
          'status': 'confirmed',
          'createdAt': '2024-01-01T00:00:00Z',
        };

        final result = CalendarEvent.fromJson(json);

        expect(result.id, equals('event-123'));
        expect(result.calendarId, equals('cal-123'));
        expect(result.title, equals('Test Event'));
        expect(result.description, equals('A test event'));
        expect(result.location, equals('Conference Room A'));
        expect(result.startDateTime, equals(DateTime.parse('2024-01-01T10:00:00Z')));
        expect(result.endDateTime, equals(DateTime.parse('2024-01-01T11:00:00Z')));
        expect(result.isAllDay, isFalse);
        expect(result.attendees, hasLength(1));
        expect(result.attendees![0].email, equals('test@example.com'));
        expect(result.recurrenceRule, equals('FREQ=WEEKLY'));
        expect(result.status, equals('confirmed'));
        expect(result.createdAt, equals(DateTime.parse('2024-01-01T00:00:00Z')));
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'event-123',
          'calendarId': 'cal-123',
          'title': 'Test Event',
          'startDateTime': '2024-01-01T10:00:00Z',
          'endDateTime': '2024-01-01T11:00:00Z',
        };

        final result = CalendarEvent.fromJson(json);

        expect(result.description, isNull);
        expect(result.location, isNull);
        expect(result.isAllDay, isFalse); // default value
        expect(result.attendees, isNull);
        expect(result.recurrenceRule, isNull);
        expect(result.status, isNull);
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('converts CalendarEvent to JSON', () {
        final result = event.toJson();

        expect(result['id'], equals('event-123'));
        expect(result['calendarId'], equals('cal-123'));
        expect(result['title'], equals('Test Event'));
        expect(result['description'], equals('A test event'));
        expect(result['location'], equals('Conference Room A'));
        expect(result['startDateTime'], equals('2024-01-01T10:00:00.000Z'));
        expect(result['endDateTime'], equals('2024-01-01T11:00:00.000Z'));
        expect(result['isAllDay'], isFalse);
        expect(result['attendees'], hasLength(1));
        expect(result['recurrenceRule'], equals('FREQ=WEEKLY'));
        expect(result['status'], equals('confirmed'));
      });

      test('includes null values', () {
        final eventWithNulls = CalendarEvent(
          id: 'event-123',
          calendarId: 'cal-123',
          title: 'Test Event',
          startDateTime: DateTime.parse('2024-01-01T10:00:00Z'),
          endDateTime: DateTime.parse('2024-01-01T11:00:00Z'),
        );

        final result = eventWithNulls.toJson();

        expect(result['description'], isNull);
        expect(result['location'], isNull);
        expect(result['attendees'], isNull);
        expect(result['recurrenceRule'], isNull);
        expect(result['status'], isNull);
        expect(result['createdAt'], isNull);
        expect(result['updatedAt'], isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final updated = event.copyWith(
          title: 'Updated Event',
          isAllDay: true,
          updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
        );

        expect(updated.id, equals(event.id));
        expect(updated.title, equals('Updated Event'));
        expect(updated.isAllDay, isTrue);
        expect(updated.updatedAt, equals(DateTime.parse('2024-01-02T00:00:00Z')));
        expect(updated.calendarId, equals(event.calendarId));
      });

      test('creates copy with same values when no changes', () {
        final copy = event.copyWith();

        expect(copy, equals(event));
        expect(identical(copy, event), isFalse);
      });
    });

    group('equality', () {
      test('events with same values are equal', () {
        final other = CalendarEvent(
          id: 'event-123',
          calendarId: 'cal-123',
          title: 'Test Event',
          description: 'A test event',
          location: 'Conference Room A',
          startDateTime: DateTime.parse('2024-01-01T10:00:00Z'),
          endDateTime: DateTime.parse('2024-01-01T11:00:00Z'),
          attendees: [
            const CalendarAttendee(
              email: 'test@example.com',
              name: 'Test User',
              responseStatus: 'accepted',
            ),
          ],
          recurrenceRule: 'FREQ=WEEKLY',
          status: 'confirmed',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        expect(event, equals(other));
        expect(event.hashCode, equals(other.hashCode));
      });

      test('events with different values are not equal', () {
        final other = event.copyWith(title: 'Different Event');

        expect(event, isNot(equals(other)));
        expect(event.hashCode, isNot(equals(other.hashCode)));
      });
    });

    test('toString contains key fields', () {
      final result = event.toString();

      expect(result, contains('event-123'));
      expect(result, contains('cal-123'));
      expect(result, contains('Test Event'));
      expect(result, contains('Conference Room A'));
    });
  });

  group('CalendarAttendee', () {
    const attendee = CalendarAttendee(
      email: 'test@example.com',
      name: 'Test User',
      responseStatus: 'accepted',
    );

    group('fromJson', () {
      test('creates CalendarAttendee from JSON', () {
        final json = {
          'email': 'test@example.com',
          'name': 'Test User',
          'responseStatus': 'accepted',
          'isOptional': false,
        };

        final result = CalendarAttendee.fromJson(json);

        expect(result.email, equals('test@example.com'));
        expect(result.name, equals('Test User'));
        expect(result.responseStatus, equals('accepted'));
        expect(result.isOptional, isFalse);
      });

      test('handles null optional fields', () {
        final json = {
          'email': 'test@example.com',
        };

        final result = CalendarAttendee.fromJson(json);

        expect(result.email, equals('test@example.com'));
        expect(result.name, isNull);
        expect(result.responseStatus, isNull);
        expect(result.isOptional, isFalse); // default value
      });
    });

    group('toJson', () {
      test('converts CalendarAttendee to JSON', () {
        final result = attendee.toJson();

        expect(result['email'], equals('test@example.com'));
        expect(result['name'], equals('Test User'));
        expect(result['responseStatus'], equals('accepted'));
        expect(result['isOptional'], isFalse);
      });

      test('includes null values', () {
        const attendeeWithNulls = CalendarAttendee(
          email: 'test@example.com',
        );

        final result = attendeeWithNulls.toJson();

        expect(result['email'], equals('test@example.com'));
        expect(result['name'], isNull);
        expect(result['responseStatus'], isNull);
        expect(result['isOptional'], isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final updated = attendee.copyWith(
          name: 'Updated User',
          responseStatus: 'declined',
        );

        expect(updated.email, equals(attendee.email));
        expect(updated.name, equals('Updated User'));
        expect(updated.responseStatus, equals('declined'));
        expect(updated.isOptional, equals(attendee.isOptional));
      });

      test('creates copy with same values when no changes', () {
        final copy = attendee.copyWith();

        expect(copy, equals(attendee));
        expect(identical(copy, attendee), isFalse);
      });
    });

    group('equality', () {
      test('attendees with same values are equal', () {
        const other = CalendarAttendee(
          email: 'test@example.com',
          name: 'Test User',
          responseStatus: 'accepted',
        );

        expect(attendee, equals(other));
        expect(attendee.hashCode, equals(other.hashCode));
      });

      test('attendees with different values are not equal', () {
        final other = attendee.copyWith(name: 'Different User');

        expect(attendee, isNot(equals(other)));
        expect(attendee.hashCode, isNot(equals(other.hashCode)));
      });
    });

    test('toString contains key fields', () {
      final result = attendee.toString();

      expect(result, contains('test@example.com'));
      expect(result, contains('Test User'));
      expect(result, contains('accepted'));
    });
  });
}