import 'package:flutter_test/flutter_test.dart';
import 'package:api_client/api_client.dart';

void main() {
  group('IOSImportModels', () {
    group('IOSContact', () {
      test('should create from database row correctly', () {
        final row = <String, dynamic>{
          'ROWID': 123,
          'DisplayName': 'John Doe',
          'First': 'John',
          'Last': 'Doe',
          'Organization': 'Acme Corp',
          'Note': 'Test note',
          'CreationDate': 1640995200, // 2022-01-01 00:00:00 UTC in seconds
          'ModificationDate': 1640995200,
        };

        final contact = IOSContact.fromDatabaseRow(row);

        expect(contact.recordId, equals(123));
        expect(contact.displayName, equals('John Doe'));
        expect(contact.firstName, equals('John'));
        expect(contact.lastName, equals('Doe'));
        expect(contact.organizationName, equals('Acme Corp'));
        expect(contact.note, equals('Test note'));
      });

      test('should handle missing optional fields', () {
        final row = <String, dynamic>{
          'ROWID': 456,
          'DisplayName': 'Jane Smith',
        };

        final contact = IOSContact.fromDatabaseRow(row);

        expect(contact.recordId, equals(456));
        expect(contact.displayName, equals('Jane Smith'));
        expect(contact.firstName, isNull);
        expect(contact.lastName, isNull);
        expect(contact.organizationName, isNull);
        expect(contact.note, isNull);
      });
    });

    group('IOSMessage', () {
      test('should create from database row correctly', () {
        // iOS messages use a different epoch (2001-01-01)
        final iosTimestamp = 694224000000000000; // Nanoseconds since 2001-01-01
        
        final row = <String, dynamic>{
          'ROWID': 789,
          'text': 'Hello world!',
          'date': iosTimestamp,
          'is_from_me': 1,
          'handle_id': 1,
          'service': 'iMessage',
          'chat_identifier': 'chat123',
          'filename': '/path/to/attachment.jpg',
          'mime_type': 'image/jpeg',
        };

        final message = IOSMessage.fromDatabaseRow(row);

        expect(message.rowId, equals(789));
        expect(message.text, equals('Hello world!'));
        expect(message.isFromMe, isTrue);
        expect(message.handleId, equals(1));
        expect(message.serviceName, equals('iMessage'));
        expect(message.chatIdentifier, equals('chat123'));
        expect(message.attachmentPath, equals('/path/to/attachment.jpg'));
        expect(message.attachmentMimeType, equals('image/jpeg'));
      });
    });

    group('IOSMediaItem', () {
      test('should create from database row correctly', () {
        // iOS media uses seconds since 2001-01-01 (NSDate)
        final iosTimestamp = 694224000.0; // Seconds since 2001-01-01
        
        final row = <String, dynamic>{
          'ZUUID': 'ABC-123-DEF',
          'ZFILENAME': 'IMG_001.jpg',
          'ZDATECREATED': iosTimestamp,
          'ZDIRECTORY': 'DCIM/Camera',
          'ZMEDIATYPE': 1, // Photo
          'ZMEDIASUBTYPE': 0,
          'ZPIXELWIDTH': 1920,
          'ZPIXELHEIGHT': 1080,
        };

        final mediaItem = IOSMediaItem.fromDatabaseRow(row);

        expect(mediaItem.uuid, equals('ABC-123-DEF'));
        expect(mediaItem.filename, equals('IMG_001.jpg'));
        expect(mediaItem.directory, equals('DCIM/Camera'));
        expect(mediaItem.mediaType, equals(1));
        expect(mediaItem.pixelWidth, equals(1920));
        expect(mediaItem.pixelHeight, equals(1080));
      });
    });

    group('IOSBackupInfo', () {
      test('should create with all properties', () {
        final lastBackup = DateTime(2023, 12, 1, 10, 30);
        
        final backupInfo = IOSBackupInfo(
          deviceName: 'John\'s iPhone',
          displayName: 'iPhone Backup',
          lastBackupDate: lastBackup,
          backupPath: '/path/to/backup',
          deviceUuid: '12345-ABCDE',
          productType: 'iPhone14,3',
          productVersion: '17.2',
          buildVersion: '21C62',
          serialNumber: 'ABC123DEF456',
          isEncrypted: true,
        );

        expect(backupInfo.deviceName, equals('John\'s iPhone'));
        expect(backupInfo.displayName, equals('iPhone Backup'));
        expect(backupInfo.lastBackupDate, equals(lastBackup));
        expect(backupInfo.backupPath, equals('/path/to/backup'));
        expect(backupInfo.deviceUuid, equals('12345-ABCDE'));
        expect(backupInfo.productType, equals('iPhone14,3'));
        expect(backupInfo.productVersion, equals('17.2'));
        expect(backupInfo.buildVersion, equals('21C62'));
        expect(backupInfo.serialNumber, equals('ABC123DEF456'));
        expect(backupInfo.isEncrypted, isTrue);
      });

      test('should create with minimum required properties', () {
        final lastBackup = DateTime(2023, 12, 1);
        
        final backupInfo = IOSBackupInfo(
          deviceName: 'iPhone',
          displayName: 'Backup',
          lastBackupDate: lastBackup,
          backupPath: '/backup',
        );

        expect(backupInfo.deviceName, equals('iPhone'));
        expect(backupInfo.displayName, equals('Backup'));
        expect(backupInfo.lastBackupDate, equals(lastBackup));
        expect(backupInfo.backupPath, equals('/backup'));
        expect(backupInfo.deviceUuid, isNull);
        expect(backupInfo.isEncrypted, isFalse);
      });
    });
  });
}