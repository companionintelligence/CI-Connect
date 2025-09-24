import 'package:flutter_test/flutter_test.dart';
import 'package:api_client/api_client.dart';

void main() {
  group('IOSImportMapper', () {
    late IOSImportMapper mapper;

    setUp(() {
      mapper = const IOSImportMapper();
    });

    group('mapContactsToCIServer', () {
      test('should map iOS contacts to CI Server contacts correctly', () {
        final iosContacts = [
          IOSContact(
            recordId: 1,
            displayName: 'John Doe',
            firstName: 'John',
            lastName: 'Doe',
            organizationName: 'Acme Corp',
            phoneNumbers: [
              const IOSPhoneNumber(value: '+1234567890', label: 'mobile'),
            ],
            emailAddresses: [
              const IOSEmailAddress(value: 'john@example.com', label: 'work'),
            ],
            note: 'Important contact',
            createdAt: DateTime(2023, 1, 1),
            modifiedAt: DateTime(2023, 6, 1),
          ),
          IOSContact(
            recordId: 2,
            displayName: 'Jane Smith',
            emailAddresses: [
              const IOSEmailAddress(value: 'jane@example.com'),
            ],
          ),
        ];

        final contacts = mapper.mapContactsToCIServer(iosContacts);

        expect(contacts, hasLength(2));

        final johnContact = contacts[0];
        expect(johnContact.id, equals('ios_contact_1'));
        expect(johnContact.name, equals('John Doe'));
        expect(johnContact.email, equals('john@example.com'));
        expect(johnContact.phone, equals('+1234567890'));
        expect(johnContact.company, equals('Acme Corp'));
        expect(johnContact.notes, equals('Important contact'));

        final janeContact = contacts[1];
        expect(janeContact.id, equals('ios_contact_2'));
        expect(janeContact.name, equals('Jane Smith'));
        expect(janeContact.email, equals('jane@example.com'));
        expect(janeContact.phone, isNull);
        expect(janeContact.company, isNull);
      });

      test('should skip contacts without names', () {
        final iosContacts = [
          IOSContact(
            recordId: 1,
            displayName: '',
            emailAddresses: [
              const IOSEmailAddress(value: 'noempty@example.com'),
            ],
          ),
          IOSContact(
            recordId: 2,
            displayName: 'Valid Name',
            emailAddresses: [
              const IOSEmailAddress(value: 'valid@example.com'),
            ],
          ),
        ];

        final contacts = mapper.mapContactsToCIServer(iosContacts);

        expect(contacts, hasLength(1));
        expect(contacts[0].name, equals('Valid Name'));
      });

      test('should combine first and last name when display name is empty', () {
        final iosContacts = [
          IOSContact(
            recordId: 1,
            displayName: '',
            firstName: 'John',
            lastName: 'Doe',
          ),
        ];

        final contacts = mapper.mapContactsToCIServer(iosContacts);

        expect(contacts, hasLength(1));
        expect(contacts[0].name, equals('John Doe'));
      });
    });

    group('mapContactsToPersons', () {
      test('should map iOS contacts to CI Server persons correctly', () {
        final iosContacts = [
          IOSContact(
            recordId: 1,
            displayName: 'John Doe',
            emailAddresses: [
              const IOSEmailAddress(value: 'john@example.com'),
            ],
            phoneNumbers: [
              const IOSPhoneNumber(value: '+1234567890'),
            ],
            createdAt: DateTime(2023, 1, 1),
          ),
        ];

        final persons = mapper.mapContactsToPersons(iosContacts);

        expect(persons, hasLength(1));
        final person = persons[0];
        expect(person.id, equals('ios_person_1'));
        expect(person.name, equals('John Doe'));
        expect(person.email, equals('john@example.com'));
        expect(person.phone, equals('+1234567890'));
      });
    });

    group('mapMessagesToContent', () {
      test('should map iOS messages to CI Server content correctly', () {
        final iosMessages = [
          IOSMessage(
            rowId: 1,
            text: 'Hello world!',
            date: DateTime(2023, 6, 1, 10, 30),
            isFromMe: true,
            serviceName: 'iMessage',
          ),
          IOSMessage(
            rowId: 2,
            text: 'Check this out',
            date: DateTime(2023, 6, 1, 11, 0),
            isFromMe: false,
            attachmentPath: '/path/to/image.jpg',
            attachmentMimeType: 'image/jpeg',
          ),
        ];

        final content = mapper.mapMessagesToContent(iosMessages);

        expect(content, hasLength(2));

        final textMessage = content[0];
        expect(textMessage.id, equals('ios_message_1'));
        expect(textMessage.name, equals('Message from 2023-06-01T10:30:00.000'));
        expect(textMessage.type, equals('message'));
        expect(textMessage.description, equals('iOS Message: Hello world!'));
        expect(textMessage.tags, contains('sent'));
        expect(textMessage.tags, contains('iMessage'));

        final attachmentMessage = content[1];
        expect(attachmentMessage.id, equals('ios_message_2'));
        expect(attachmentMessage.name, equals('image.jpg'));
        expect(attachmentMessage.type, equals('attachment'));
        expect(attachmentMessage.mimeType, equals('image/jpeg'));
        expect(attachmentMessage.tags, contains('received'));
      });

      test('should skip empty messages', () {
        final iosMessages = [
          IOSMessage(
            rowId: 1,
            text: '',
            date: DateTime(2023, 6, 1),
            isFromMe: true,
          ),
          IOSMessage(
            rowId: 2,
            text: 'Valid message',
            date: DateTime(2023, 6, 1),
            isFromMe: false,
          ),
        ];

        final content = mapper.mapMessagesToContent(iosMessages);

        expect(content, hasLength(1));
        expect(content[0].description, equals('iOS Message: Valid message'));
      });
    });

    group('mapMediaToContent', () {
      test('should map iOS media items to CI Server content correctly', () {
        final mediaItems = [
          IOSMediaItem(
            uuid: 'ABC-123',
            filename: 'IMG_001.jpg',
            dateCreated: DateTime(2023, 6, 1),
            mediaType: 1, // Photo
            pixelWidth: 1920,
            pixelHeight: 1080,
          ),
          IOSMediaItem(
            uuid: 'DEF-456',
            filename: 'VID_002.mp4',
            dateCreated: DateTime(2023, 6, 2),
            mediaType: 2, // Video
            duration: 30.5,
          ),
        ];

        final content = mapper.mapMediaToContent(mediaItems);

        expect(content, hasLength(2));

        final photo = content[0];
        expect(photo.id, equals('ios_media_ABC-123'));
        expect(photo.name, equals('IMG_001.jpg'));
        expect(photo.type, equals('image'));
        expect(photo.mimeType, equals('image/jpeg'));
        expect(photo.tags, contains('1920x1080'));

        final video = content[1];
        expect(video.id, equals('ios_media_DEF-456'));
        expect(video.name, equals('VID_002.mp4'));
        expect(video.type, equals('video'));
        expect(video.mimeType, equals('video/mp4'));
      });
    });

    group('mapAddressesToPlaces', () {
      test('should map iOS addresses to CI Server places correctly', () {
        final iosContacts = [
          IOSContact(
            recordId: 1,
            displayName: 'John Doe',
            addresses: [
              const IOSAddress(
                street: '123 Main St',
                city: 'Anytown',
                state: 'CA',
                zipCode: '12345',
                country: 'USA',
                label: 'home',
              ),
              const IOSAddress(
                street: '456 Work Ave',
                city: 'Business City',
                state: 'NY',
                label: 'work',
              ),
            ],
            createdAt: DateTime(2023, 1, 1),
          ),
        ];

        final places = mapper.mapAddressesToPlaces(iosContacts);

        expect(places, hasLength(2));

        final homePlace = places[0];
        expect(homePlace.id, equals('ios_place_1_0'));
        expect(homePlace.name, equals('John Doe - home'));
        expect(homePlace.address, equals('123 Main St, Anytown, CA, 12345, USA'));

        final workPlace = places[1];
        expect(workPlace.id, equals('ios_place_1_1'));
        expect(workPlace.name, equals('John Doe - work'));
        expect(workPlace.address, equals('456 Work Ave, Business City, NY'));
      });

      test('should skip empty addresses', () {
        final iosContacts = [
          IOSContact(
            recordId: 1,
            displayName: 'John Doe',
            addresses: [
              const IOSAddress(), // Empty address
              const IOSAddress(
                street: '123 Main St',
                city: 'Anytown',
              ),
            ],
          ),
        ];

        final places = mapper.mapAddressesToPlaces(iosContacts);

        expect(places, hasLength(1));
        expect(places[0].address, equals('123 Main St, Anytown'));
      });
    });

    group('createImportSummary', () {
      test('should create comprehensive import summary', () {
        final startTime = DateTime(2023, 6, 1, 10, 0);
        final endTime = DateTime(2023, 6, 1, 10, 30);
        
        final contacts = [
          IOSContact(recordId: 1, displayName: 'John Doe'),
          IOSContact(recordId: 2, displayName: 'Jane Smith'),
        ];
        
        final messages = [
          IOSMessage(rowId: 1, text: 'Hello', date: DateTime.now(), isFromMe: true),
          IOSMessage(rowId: 2, text: 'Hi', date: DateTime.now(), isFromMe: false),
          IOSMessage(rowId: 3, text: 'Bye', date: DateTime.now(), isFromMe: true),
        ];
        
        final mediaItems = [
          IOSMediaItem(uuid: 'A', filename: 'img1.jpg', dateCreated: DateTime.now()),
        ];

        final summary = mapper.createImportSummary(
          contacts: contacts,
          messages: messages,
          mediaItems: mediaItems,
          importStartTime: startTime,
          importEndTime: endTime,
        );

        expect(summary.totalContacts, equals(2));
        expect(summary.totalMessages, equals(3));
        expect(summary.totalMediaItems, equals(1));
        expect(summary.contactsImported, equals(2));
        expect(summary.messagesImported, equals(3));
        expect(summary.mediaImported, equals(1));
        expect(summary.importDuration, equals(const Duration(minutes: 30)));
        expect(summary.importedAt, equals(endTime));
      });
    });
  });
}