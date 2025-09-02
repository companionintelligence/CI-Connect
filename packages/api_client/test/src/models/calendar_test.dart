import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar', () {
    const calendar = Calendar(
      id: 'cal1',
      name: 'Test Calendar',
      description: 'A test calendar',
      isEnabled: true,
      source: 'google',
      lastSyncedAt: null,
      createdAt: null,
    );

    group('fromJson', () {
      test('creates instance from valid JSON', () {
        final json = {
          'id': 'cal1',
          'name': 'Test Calendar',
          'description': 'A test calendar',
          'isEnabled': true,
          'source': 'google',
          'createdAt': '2023-01-01T00:00:00.000Z',
        };

        final result = Calendar.fromJson(json);

        expect(result.id, 'cal1');
        expect(result.name, 'Test Calendar');
        expect(result.description, 'A test calendar');
        expect(result.isEnabled, true);
        expect(result.source, 'google');
        expect(result.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
        expect(result.lastSyncedAt, null);
        expect(result.updatedAt, null);
      });

      test('handles optional fields correctly', () {
        final json = {
          'id': 'cal1',
          'name': 'Test Calendar',
          'isEnabled': true,
          'source': 'google',
          'createdAt': '2023-01-01T00:00:00.000Z',
          'lastSyncedAt': '2023-01-02T00:00:00.000Z',
          'updatedAt': '2023-01-03T00:00:00.000Z',
        };

        final result = Calendar.fromJson(json);

        expect(result.description, null);
        expect(result.lastSyncedAt, DateTime.parse('2023-01-02T00:00:00.000Z'));
        expect(result.updatedAt, DateTime.parse('2023-01-03T00:00:00.000Z'));
      });
    });

    group('toJson', () {
      test('converts to JSON correctly', () {
        final testCalendar = Calendar(
          id: 'cal1',
          name: 'Test Calendar',
          description: 'A test calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
          lastSyncedAt: DateTime.parse('2023-01-02T00:00:00.000Z'),
          updatedAt: DateTime.parse('2023-01-03T00:00:00.000Z'),
        );

        final result = testCalendar.toJson();

        expect(result['id'], 'cal1');
        expect(result['name'], 'Test Calendar');
        expect(result['description'], 'A test calendar');
        expect(result['isEnabled'], true);
        expect(result['source'], 'google');
        expect(result['createdAt'], '2023-01-01T00:00:00.000Z');
        expect(result['lastSyncedAt'], '2023-01-02T00:00:00.000Z');
        expect(result['updatedAt'], '2023-01-03T00:00:00.000Z');
      });

      test('handles null values correctly', () {
        final testCalendar = Calendar(
          id: 'cal1',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final result = testCalendar.toJson();

        expect(result['description'], null);
        expect(result['lastSyncedAt'], null);
        expect(result['updatedAt'], null);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Calendar(
          id: 'cal1',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final copy = original.copyWith(
          name: 'Updated Calendar',
          isEnabled: false,
        );

        expect(copy.id, original.id);
        expect(copy.name, 'Updated Calendar');
        expect(copy.isEnabled, false);
        expect(copy.source, original.source);
        expect(copy.createdAt, original.createdAt);
      });
    });

    group('equality', () {
      test('returns true for identical calendars', () {
        final calendar1 = Calendar(
          id: 'cal1',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final calendar2 = Calendar(
          id: 'cal1',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        expect(calendar1, calendar2);
        expect(calendar1.hashCode, calendar2.hashCode);
      });

      test('returns false for different calendars', () {
        final calendar1 = Calendar(
          id: 'cal1',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final calendar2 = Calendar(
          id: 'cal2',
          name: 'Test Calendar',
          isEnabled: true,
          source: 'google',
          createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        expect(calendar1, isNot(calendar2));
      });
    });
  });
}