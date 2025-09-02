import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar', () {
    final calendar = Calendar(
      id: 'cal-123',
      name: 'Test Calendar',
      description: 'A test calendar',
      color: '#4285F4',
      timeZone: 'America/New_York',
      isEnabled: true,
      source: 'google',
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    group('fromJson', () {
      test('creates Calendar from JSON', () {
        final json = {
          'id': 'cal-123',
          'name': 'Test Calendar',
          'description': 'A test calendar',
          'color': '#4285F4',
          'timeZone': 'America/New_York',
          'isEnabled': true,
          'source': 'google',
          'createdAt': '2024-01-01T00:00:00Z',
        };

        final result = Calendar.fromJson(json);

        expect(result.id, equals('cal-123'));
        expect(result.name, equals('Test Calendar'));
        expect(result.description, equals('A test calendar'));
        expect(result.color, equals('#4285F4'));
        expect(result.timeZone, equals('America/New_York'));
        expect(result.isEnabled, isTrue);
        expect(result.source, equals('google'));
        expect(result.createdAt, equals(DateTime.parse('2024-01-01T00:00:00Z')));
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'cal-123',
          'name': 'Test Calendar',
          'isEnabled': true,
          'source': 'google',
          'createdAt': '2024-01-01T00:00:00Z',
        };

        final result = Calendar.fromJson(json);

        expect(result.description, isNull);
        expect(result.color, isNull);
        expect(result.timeZone, isNull);
        expect(result.lastSyncedAt, isNull);
        expect(result.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('converts Calendar to JSON', () {
        final result = calendar.toJson();

        expect(result['id'], equals('cal-123'));
        expect(result['name'], equals('Test Calendar'));
        expect(result['description'], equals('A test calendar'));
        expect(result['color'], equals('#4285F4'));
        expect(result['timeZone'], equals('America/New_York'));
        expect(result['isEnabled'], isTrue);
        expect(result['source'], equals('google'));
        expect(result['createdAt'], equals('2024-01-01T00:00:00Z'));
      });

      test('includes null values', () {
        final calendarWithNulls = Calendar(
          id: 'cal-123',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        final result = calendarWithNulls.toJson();

        expect(result['description'], isNull);
        expect(result['color'], isNull);
        expect(result['timeZone'], isNull);
        expect(result['lastSyncedAt'], isNull);
        expect(result['updatedAt'], isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final updated = calendar.copyWith(
          name: 'Updated Calendar',
          isEnabled: false,
          lastSyncedAt: DateTime.parse('2024-01-02T00:00:00Z'),
        );

        expect(updated.id, equals(calendar.id));
        expect(updated.name, equals('Updated Calendar'));
        expect(updated.isEnabled, isFalse);
        expect(updated.lastSyncedAt, equals(DateTime.parse('2024-01-02T00:00:00Z')));
        expect(updated.source, equals(calendar.source));
      });

      test('creates copy with same values when no changes', () {
        final copy = calendar.copyWith();

        expect(copy, equals(calendar));
        expect(identical(copy, calendar), isFalse);
      });
    });

    group('equality', () {
      test('calendars with same values are equal', () {
        final other = Calendar(
          id: 'cal-123',
          name: 'Test Calendar',
          description: 'A test calendar',
          color: '#4285F4',
          timeZone: 'America/New_York',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        expect(calendar, equals(other));
        expect(calendar.hashCode, equals(other.hashCode));
      });

      test('calendars with different values are not equal', () {
        final other = calendar.copyWith(name: 'Different Calendar');

        expect(calendar, isNot(equals(other)));
        expect(calendar.hashCode, isNot(equals(other.hashCode)));
      });
    });

    test('toString contains all fields', () {
      final result = calendar.toString();

      expect(result, contains('cal-123'));
      expect(result, contains('Test Calendar'));
      expect(result, contains('A test calendar'));
      expect(result, contains('#4285F4'));
      expect(result, contains('America/New_York'));
      expect(result, contains('true'));
      expect(result, contains('google'));
    });
  });
}