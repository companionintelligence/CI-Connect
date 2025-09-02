import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClient', () {
    test('can be instantiated', () {
      final apiClient = ApiClient(baseUrl: 'https://api.example.com');
      expect(apiClient, isNotNull);
    });
  });

  group('API Models', () {
    test('Person can be serialized to/from JSON', () {
      final person = Person(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final json = person.toJson();
      expect(json['id'], equals('1'));
      expect(json['name'], equals('John Doe'));
      expect(json['email'], equals('john@example.com'));

      final fromJson = Person.fromJson(json);
      expect(fromJson.id, equals(person.id));
      expect(fromJson.name, equals(person.name));
      expect(fromJson.email, equals(person.email));
    });

    test('Place can be serialized to/from JSON', () {
      final place = Place(
        id: '1',
        name: 'Central Park',
        address: 'New York, NY',
        latitude: 40.7829,
        longitude: -73.9654,
        description: 'A large public park',
      );

      final json = place.toJson();
      expect(json['id'], equals('1'));
      expect(json['name'], equals('Central Park'));
      expect(json['address'], equals('New York, NY'));

      final fromJson = Place.fromJson(json);
      expect(fromJson.id, equals(place.id));
      expect(fromJson.name, equals(place.name));
      expect(fromJson.address, equals(place.address));
    });

    test('Content can be serialized to/from JSON', () {
      final content = Content(
        id: '1',
        name: 'document.pdf',
        type: 'document',
        filePath: '/uploads/document.pdf',
        fileSize: 1024,
        mimeType: 'application/pdf',
        description: 'A sample document',
        tags: ['important', 'work'],
      );

      final json = content.toJson();
      expect(json['id'], equals('1'));
      expect(json['name'], equals('document.pdf'));
      expect(json['type'], equals('document'));

      final fromJson = Content.fromJson(json);
      expect(fromJson.id, equals(content.id));
      expect(fromJson.name, equals(content.name));
      expect(fromJson.type, equals(content.type));
    });

    test('Contact can be serialized to/from JSON', () {
      final contact = Contact(
        id: '1',
        name: 'Jane Smith',
        email: 'jane@company.com',
        phone: '+0987654321',
        company: 'Tech Corp',
        notes: 'Important client',
      );

      final json = contact.toJson();
      expect(json['id'], equals('1'));
      expect(json['name'], equals('Jane Smith'));
      expect(json['company'], equals('Tech Corp'));

      final fromJson = Contact.fromJson(json);
      expect(fromJson.id, equals(contact.id));
      expect(fromJson.name, equals(contact.name));
      expect(fromJson.company, equals(contact.company));
    });

    test('Thing can be serialized to/from JSON', () {
      final thing = Thing(
        id: '1',
        name: 'Smart Device',
        category: 'electronics',
        description: 'IoT sensor device',
        properties: {
          'battery': '85%',
          'status': 'active',
        },
      );

      final json = thing.toJson();
      expect(json['id'], equals('1'));
      expect(json['name'], equals('Smart Device'));
      expect(json['category'], equals('electronics'));

      final fromJson = Thing.fromJson(json);
      expect(fromJson.id, equals(thing.id));
      expect(fromJson.name, equals(thing.name));
      expect(fromJson.category, equals(thing.category));
    });
  });
}    });
  });
}
