# iOS Import Tools Documentation

## Overview

The iOS Import Tools provide comprehensive functionality for extracting data from iOS device backups and importing it into the CI-Server. This system is designed to work on desktop platforms (macOS and Windows) where iTunes or Finder backups are available.

## Architecture

The iOS Import system is built with a modular architecture consisting of several key components:

### Core Components

1. **Data Models** (`ios_import_models.dart`)
   - Represents iOS data structures (contacts, messages, media, locations)
   - Handles parsing from iOS backup databases
   - Type-safe data representation

2. **Backup Service** (`ios_backup_service.dart`)  
   - Discovers iTunes/Finder backups on the system
   - Reads SQLite databases from backup files
   - Extracts raw data from iOS backup structures

3. **Import Mapper** (`ios_import_mapper.dart`)
   - Maps iOS data structures to CI-Server format
   - Handles data transformation and validation
   - Creates import summaries and statistics

4. **Import Service** (`ios_import_service.dart`)
   - Orchestrates the complete import process
   - Provides progress tracking and error handling
   - Uploads mapped data to CI-Server

5. **User Interface** (`IOSImportPage`)
   - Desktop-focused UI for backup selection
   - Real-time progress tracking
   - Import configuration options

## Supported Data Types

### Contacts
- **Source**: iOS AddressBook database (`ABPerson` table)
- **Maps to**: CI-Server `Contact` and/or `Person` entities
- **Includes**: Names, phone numbers, email addresses, companies, notes, addresses

### Messages  
- **Source**: iOS Messages database (`message` table)
- **Maps to**: CI-Server `Content` entities
- **Includes**: Text messages, attachments, timestamps, sender information

### Media
- **Source**: iOS Photos database (`ZGENERICASSET` table)  
- **Maps to**: CI-Server `Content` entities
- **Includes**: Photos, videos, metadata, creation dates

### Places
- **Source**: Contact addresses from iOS AddressBook
- **Maps to**: CI-Server `Place` entities
- **Includes**: Physical addresses, location names, associated contacts

## Usage

### Basic Integration

```dart
import 'package:api_client/api_client.dart';

// Create CI-Server client
final ciServerClient = CIServerClient(
  dio: Dio(),
  baseUrl: 'https://your-ci-server.com/api',
  apiKey: 'your-api-key',
);

// Create import service
final importService = IOSImportService(
  ciServerClient: ciServerClient,
  studioId: 'your-studio-id',
);

// Discover available backups
final backups = await importService.discoverBackups();

// Configure import options
final options = IOSImportOptions(
  importContacts: true,
  importMessages: true,
  importMedia: true,
  importPlaces: true,
);

// Import from selected backup
final summary = await importService.importFromBackup(
  backups.first,
  options: options,
);

print('Import completed: ${summary.contactsImported} contacts imported');
```

### Progress Tracking

```dart
// Listen to import progress
importService.progressStream.listen((progress) {
  print('${progress.stage}: ${progress.message}');
  
  if (progress.percentage != null) {
    print('Progress: ${progress.percentage!.toStringAsFixed(1)}%');
  }
});
```

### UI Integration

```dart
import 'package:app_ui/app_ui.dart';

// Navigate to iOS Import page
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (context) => IOSImportPage(
      ciServerClient: ciServerClient,
      studioId: studioId,
    ),
  ),
);
```

## Platform Requirements

### macOS
- **Backup Location**: `~/Library/Application Support/MobileSync/Backup`
- **Requirements**: iTunes or Finder backups available
- **Permissions**: File system access to backup directory

### Windows  
- **Backup Location**: `%APPDATA%/Apple Computer/MobileSync/Backup`
- **Requirements**: iTunes installed and backups created
- **Permissions**: File system access to backup directory

## Data Mapping

### iOS Contact → CI-Server Contact
```dart
IOSContact(
  displayName: 'John Doe',
  phoneNumbers: [IOSPhoneNumber(value: '+1234567890')],
  emailAddresses: [IOSEmailAddress(value: 'john@example.com')],
  organizationName: 'Acme Corp',
)
// Maps to:
Contact(
  id: 'ios_contact_123',
  name: 'John Doe',
  phone: '+1234567890', 
  email: 'john@example.com',
  company: 'Acme Corp',
)
```

### iOS Message → CI-Server Content
```dart
IOSMessage(
  text: 'Hello world!',
  date: DateTime(2023, 6, 1),
  isFromMe: true,
  serviceName: 'iMessage',
)
// Maps to:
Content(
  id: 'ios_message_456',
  name: 'Message from 2023-06-01T00:00:00.000',
  type: 'message',
  description: 'iOS Message: Hello world!',
  tags: ['ios_import', 'message', 'sent', 'iMessage'],
)
```

## Configuration Options

### IOSImportOptions
- `importContacts`: Import contacts as Contact entities
- `importContactsAsPersons`: Also import contacts as Person entities  
- `importMessages`: Import text messages and attachments
- `importMedia`: Import photos and videos from Photos app
- `importPlaces`: Import places from contact addresses
- `maxMessages`: Limit number of messages to import (default: 10,000)
- `maxMediaItems`: Limit number of media items to import (default: 5,000)

## Error Handling

The system is designed to be resilient to errors:

- **Individual item failures**: Continue processing other items
- **Database connection issues**: Graceful error reporting
- **Platform validation**: Checks for supported platforms
- **Backup accessibility**: Validates backup files exist and are readable
- **API errors**: Continues with remaining items if individual uploads fail

## Performance Considerations

- **Large datasets**: Progress tracking for long-running operations
- **Memory usage**: Processes data in batches to avoid memory issues
- **Network resilience**: Retries and error handling for API calls
- **Database efficiency**: Uses indexed queries where possible

## Security & Privacy

- **Local processing**: All data extraction happens locally
- **No external dependencies**: Uses only iOS backup files on local system
- **Encrypted backups**: Detects but currently doesn't support encrypted backups
- **Data validation**: Sanitizes and validates data before upload

## Testing

Comprehensive test coverage includes:

- **Unit tests** for all data models and mapping logic
- **Integration tests** for service interactions  
- **Mock data** for testing without real iOS backups
- **Error scenario testing** for resilience validation

Run tests:
```bash
cd packages/api_client
flutter test test/src/models/ios_import_models_test.dart
flutter test test/src/services/ios_import_mapper_test.dart
```

## Limitations & Future Enhancements

### Current Limitations
- **Encrypted backups**: Not currently supported (requires password)
- **Real-time sync**: Only works with backup files, not live devices
- **Partial backups**: Requires full iTunes/Finder backups
- **iOS version compatibility**: Tested with iOS 14-17 backup formats

### Planned Enhancements  
- **Encrypted backup support**: Password-based decryption
- **Live device access**: Direct iOS device communication
- **Incremental imports**: Only import new/changed data
- **Additional data types**: Call logs, Safari bookmarks, Notes app
- **Cloud backup support**: iCloud backup integration
- **Batch processing**: Improved performance for large datasets

## Troubleshooting

### Common Issues

1. **"No backups found"**
   - Verify iTunes/Finder backups exist
   - Check backup directory permissions
   - Ensure backups are not corrupted

2. **"Database not found"**
   - Backup may be incomplete or corrupted
   - Try with a different backup
   - Verify iOS version compatibility

3. **"Import failed"**
   - Check CI-Server connectivity
   - Verify API credentials
   - Check server logs for detailed errors

4. **"Platform not supported"**
   - iOS Import only works on macOS and Windows
   - Mobile platforms cannot access backup files

### Debug Mode

Enable detailed logging:
```dart
// Enable debug mode for detailed logging
final importService = IOSImportService(
  ciServerClient: ciServerClient,
  studioId: studioId,
  debugMode: true, // If implemented
);
```

## References

- [iTunes Backup Format Documentation](https://github.com/jsharkey13/iphone_backup_decrypt)
- [iOS Database Schema Reference](https://github.com/iOSForensics) 
- [CI-Server API Documentation](https://github.com/companionintelligence/CI-Server/tree/main/backend/apps/api)
- [Similar Tools Analysis](https://imazing.com/guides/how-to-access-iphone-backup-files-on-mac-and-pc)