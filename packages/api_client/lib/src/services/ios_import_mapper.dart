import 'dart:io';
import '../models/models.dart';

/// {@template ios_import_mapper}
/// Service for mapping iOS data to CI-Server format
/// {@endtemplate}
class IOSImportMapper {
  /// {@macro ios_import_mapper}
  const IOSImportMapper();

  /// Maps iOS contacts to CI-Server Contact format
  List<Contact> mapContactsToCIServer(List<IOSContact> iosContacts) {
    return iosContacts.map((iosContact) {
      // Prefer display name, fallback to combined first/last name
      final name = iosContact.displayName.isNotEmpty 
          ? iosContact.displayName
          : _combineName(iosContact.firstName, iosContact.lastName);
      
      if (name.isEmpty) {
        return null; // Skip contacts without names
      }

      // Get primary phone and email
      final primaryPhone = iosContact.phoneNumbers.isNotEmpty 
          ? iosContact.phoneNumbers.first.value 
          : null;
      final primaryEmail = iosContact.emailAddresses.isNotEmpty 
          ? iosContact.emailAddresses.first.value 
          : null;

      return Contact(
        id: 'ios_contact_${iosContact.recordId}',
        name: name,
        email: primaryEmail,
        phone: primaryPhone,
        company: iosContact.organizationName,
        notes: iosContact.note,
        createdAt: iosContact.createdAt ?? DateTime.now(),
        updatedAt: iosContact.modifiedAt ?? DateTime.now(),
      );
    })
    .where((contact) => contact != null)
    .cast<Contact>()
    .toList();
  }

  /// Maps iOS contacts to CI-Server Person format
  List<Person> mapContactsToPersons(List<IOSContact> iosContacts) {
    return iosContacts.map((iosContact) {
      final name = iosContact.displayName.isNotEmpty 
          ? iosContact.displayName
          : _combineName(iosContact.firstName, iosContact.lastName);
      
      if (name.isEmpty) {
        return null;
      }

      final primaryPhone = iosContact.phoneNumbers.isNotEmpty 
          ? iosContact.phoneNumbers.first.value 
          : null;
      final primaryEmail = iosContact.emailAddresses.isNotEmpty 
          ? iosContact.emailAddresses.first.value 
          : null;

      return Person(
        id: 'ios_person_${iosContact.recordId}',
        name: name,
        email: primaryEmail,
        phone: primaryPhone,
        createdAt: iosContact.createdAt ?? DateTime.now(),
        updatedAt: iosContact.modifiedAt ?? DateTime.now(),
      );
    })
    .where((person) => person != null)
    .cast<Person>()
    .toList();
  }

  /// Maps iOS messages to CI-Server Content format
  List<Content> mapMessagesToContent(List<IOSMessage> iosMessages) {
    return iosMessages.map((message) {
      if (message.text.isEmpty && message.attachmentPath == null) {
        return null; // Skip empty messages
      }

      final isAttachment = message.attachmentPath != null;
      final contentType = isAttachment ? 'attachment' : 'message';
      
      // Generate a meaningful name for the content
      final name = isAttachment 
          ? _extractFileName(message.attachmentPath!)
          : 'Message from ${message.date.toIso8601String()}';

      final description = isAttachment 
          ? 'iOS Message Attachment: ${message.text}'
          : 'iOS Message: ${message.text}';

      return Content(
        id: 'ios_message_${message.rowId}',
        name: name,
        type: contentType,
        description: description.length > 500 ? '${description.substring(0, 500)}...' : description,
        mimeType: message.attachmentMimeType,
        tags: [
          'ios_import',
          'message',
          if (message.isFromMe) 'sent' else 'received',
          if (message.serviceName != null) message.serviceName!,
        ],
        createdAt: message.date,
        updatedAt: message.date,
      );
    })
    .where((content) => content != null)
    .cast<Content>()
    .toList();
  }

  /// Maps iOS media items to CI-Server Content format
  List<Content> mapMediaToContent(List<IOSMediaItem> mediaItems) {
    return mediaItems.map((mediaItem) {
      final mediaType = _getMediaTypeString(mediaItem.mediaType);
      final mimeType = _guessMimeType(mediaItem.filename);
      
      return Content(
        id: 'ios_media_${mediaItem.uuid}',
        name: mediaItem.filename,
        type: mediaType,
        description: 'iOS ${mediaType.capitalize()} imported from Photos app',
        mimeType: mimeType,
        fileSize: null, // Would need to check actual file
        tags: [
          'ios_import',
          'photos',
          mediaType,
          if (mediaItem.pixelWidth != null && mediaItem.pixelHeight != null)
            '${mediaItem.pixelWidth}x${mediaItem.pixelHeight}',
        ],
        createdAt: mediaItem.dateCreated,
        updatedAt: mediaItem.dateCreated,
      );
    }).toList();
  }

  /// Maps iOS addresses to CI-Server Place format
  List<Place> mapAddressesToPlaces(List<IOSContact> iosContacts) {
    final places = <Place>[];
    
    for (final contact in iosContacts) {
      for (int i = 0; i < contact.addresses.length; i++) {
        final address = contact.addresses[i];
        if (address.street == null && address.city == null) {
          continue; // Skip empty addresses
        }

        final addressString = [
          address.street,
          address.city,
          address.state,
          address.zipCode,
          address.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        if (addressString.isEmpty) {
          continue;
        }

        final placeName = address.label?.isNotEmpty == true
            ? '${contact.displayName} - ${address.label}'
            : '${contact.displayName} - Address ${i + 1}';

        places.add(Place(
          id: 'ios_place_${contact.recordId}_$i',
          name: placeName,
          address: addressString,
          description: 'Address imported from iOS contact: ${contact.displayName}',
          createdAt: contact.createdAt ?? DateTime.now(),
          updatedAt: contact.modifiedAt ?? DateTime.now(),
        ));
      }
    }
    
    return places;
  }

  /// Creates an import summary with statistics
  IOSImportSummary createImportSummary({
    required List<IOSContact> contacts,
    required List<IOSMessage> messages,
    required List<IOSMediaItem> mediaItems,
    required DateTime importStartTime,
    required DateTime importEndTime,
  }) {
    final contactsAsContacts = mapContactsToCIServer(contacts);
    final contactsAsPersons = mapContactsToPersons(contacts);
    final messagesAsContent = mapMessagesToContent(messages);
    final mediaAsContent = mapMediaToContent(mediaItems);
    final addressesAsPlaces = mapAddressesToPlaces(contacts);

    return IOSImportSummary(
      totalContacts: contacts.length,
      totalMessages: messages.length,
      totalMediaItems: mediaItems.length,
      contactsImported: contactsAsContacts.length,
      personsImported: contactsAsPersons.length,
      messagesImported: messagesAsContent.length,
      mediaImported: mediaAsContent.length,
      placesImported: addressesAsPlaces.length,
      importDuration: importEndTime.difference(importStartTime),
      importedAt: importEndTime,
    );
  }

  /// Combines first and last name
  String _combineName(String? firstName, String? lastName) {
    final parts = [firstName, lastName]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(' ');
  }

  /// Extracts filename from path
  String _extractFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  /// Gets media type string from iOS media type code
  String _getMediaTypeString(int? mediaType) {
    switch (mediaType) {
      case 1:
        return 'image';
      case 2:
        return 'video';
      default:
        return 'media';
    }
  }

  /// Guesses MIME type from filename
  String? _guessMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return null;
    }
  }
}

/// {@template ios_import_summary}
/// Summary of iOS import operation results
/// {@endtemplate}
class IOSImportSummary {
  /// {@macro ios_import_summary}
  const IOSImportSummary({
    required this.totalContacts,
    required this.totalMessages,
    required this.totalMediaItems,
    required this.contactsImported,
    required this.personsImported,
    required this.messagesImported,
    required this.mediaImported,
    required this.placesImported,
    required this.importDuration,
    required this.importedAt,
  });

  /// Total number of contacts found in backup
  final int totalContacts;
  
  /// Total number of messages found in backup
  final int totalMessages;
  
  /// Total number of media items found in backup
  final int totalMediaItems;
  
  /// Number of contacts successfully imported
  final int contactsImported;
  
  /// Number of persons successfully imported
  final int personsImported;
  
  /// Number of messages successfully imported
  final int messagesImported;
  
  /// Number of media items successfully imported
  final int mediaImported;
  
  /// Number of places successfully imported
  final int placesImported;
  
  /// Duration of import operation
  final Duration importDuration;
  
  /// Timestamp when import completed
  final DateTime importedAt;

  @override
  String toString() {
    return 'IOSImportSummary(\n'
        '  totalContacts: $totalContacts,\n'
        '  totalMessages: $totalMessages,\n'
        '  totalMediaItems: $totalMediaItems,\n'
        '  contactsImported: $contactsImported,\n'
        '  personsImported: $personsImported,\n'
        '  messagesImported: $messagesImported,\n'
        '  mediaImported: $mediaImported,\n'
        '  placesImported: $placesImported,\n'
        '  importDuration: $importDuration,\n'
        '  importedAt: $importedAt\n'
        ')';
  }
}

/// String extension for capitalizing
extension StringExtension on String {
  /// Capitalizes the first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}