import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('HealthData', () {
    test('can be created from JSON', () {
      final json = {
        'id': 'health_001',
        'contactId': 'contact_123',
        'dataType': 'heart_rate',
        'value': '72',
        'unit': 'bpm',
        'timestamp': '2024-01-01T10:00:00.000Z',
        'notes': 'Resting heart rate',
        'metadata': {'device': 'fitness_tracker'}
      };

      final healthData = HealthData.fromJson(json);

      expect(healthData.id, equals('health_001'));
      expect(healthData.contactId, equals('contact_123'));
      expect(healthData.dataType, equals('heart_rate'));
      expect(healthData.value, equals('72'));
      expect(healthData.unit, equals('bpm'));
      expect(healthData.notes, equals('Resting heart rate'));
      expect(healthData.metadata, equals({'device': 'fitness_tracker'}));
    });

    test('can be converted to JSON', () {
      final timestamp = DateTime.parse('2024-01-01T10:00:00.000Z');
      final healthData = HealthData(
        id: 'health_001',
        contactId: 'contact_123',
        dataType: 'heart_rate',
        value: '72',
        unit: 'bpm',
        timestamp: timestamp,
        notes: 'Resting heart rate',
        metadata: {'device': 'fitness_tracker'},
      );

      final json = healthData.toJson();

      expect(json['id'], equals('health_001'));
      expect(json['contactId'], equals('contact_123'));
      expect(json['dataType'], equals('heart_rate'));
      expect(json['value'], equals('72'));
      expect(json['unit'], equals('bpm'));
      expect(json['timestamp'], equals(timestamp.toIso8601String()));
      expect(json['notes'], equals('Resting heart rate'));
      expect(json['metadata'], equals({'device': 'fitness_tracker'}));
    });

    test('copyWith creates new instance with updated values', () {
      final original = HealthData(
        id: 'health_001',
        contactId: 'contact_123',
        dataType: 'heart_rate',
        value: '72',
        unit: 'bpm',
        timestamp: DateTime.now(),
      );

      final copy = original.copyWith(value: '75', unit: 'beats/min');

      expect(copy.id, equals(original.id));
      expect(copy.contactId, equals(original.contactId));
      expect(copy.value, equals('75'));
      expect(copy.unit, equals('beats/min'));
    });

    test('equality works correctly', () {
      final timestamp = DateTime.now();
      final healthData1 = HealthData(
        id: 'health_001',
        contactId: 'contact_123',
        dataType: 'heart_rate',
        value: '72',
        unit: 'bpm',
        timestamp: timestamp,
      );

      final healthData2 = HealthData(
        id: 'health_001',
        contactId: 'contact_123',
        dataType: 'heart_rate',
        value: '72',
        unit: 'bpm',
        timestamp: timestamp,
      );

      final healthData3 = healthData1.copyWith(value: '75');

      expect(healthData1, equals(healthData2));
      expect(healthData1, isNot(equals(healthData3)));
    });
  });
}