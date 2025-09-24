/// iOS Import data models for parsing iOS backup data
library;

/// {@template ios_contact}
/// Represents a contact from iOS backup data
/// {@endtemplate}
class IOSContact {
  /// {@macro ios_contact}
  const IOSContact({
    required this.recordId,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.organizationName,
    this.phoneNumbers = const [],
    this.emailAddresses = const [],
    this.addresses = const [],
    this.note,
    this.createdAt,
    this.modifiedAt,
  });

  /// Creates an [IOSContact] from iOS backup database row
  factory IOSContact.fromDatabaseRow(Map<String, dynamic> row) {
    return IOSContact(
      recordId: row['ROWID'] as int,
      displayName: row['DisplayName'] as String? ?? '',
      firstName: row['First'] as String?,
      lastName: row['Last'] as String?,
      organizationName: row['Organization'] as String?,
      note: row['Note'] as String?,
      createdAt: row['CreationDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((row['CreationDate'] as num).toInt() * 1000)
          : null,
      modifiedAt: row['ModificationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch((row['ModificationDate'] as num).toInt() * 1000)
          : null,
    );
  }

  /// Record ID from iOS database
  final int recordId;
  
  /// Display name for the contact
  final String displayName;
  
  /// First name
  final String? firstName;
  
  /// Last name  
  final String? lastName;
  
  /// Organization/Company name
  final String? organizationName;
  
  /// List of phone numbers
  final List<IOSPhoneNumber> phoneNumbers;
  
  /// List of email addresses
  final List<IOSEmailAddress> emailAddresses;
  
  /// List of addresses
  final List<IOSAddress> addresses;
  
  /// Contact notes
  final String? note;
  
  /// Creation date
  final DateTime? createdAt;
  
  /// Last modification date
  final DateTime? modifiedAt;

  @override
  String toString() {
    return 'IOSContact(recordId: $recordId, displayName: $displayName, '
        'firstName: $firstName, lastName: $lastName)';
  }
}

/// {@template ios_phone_number}
/// Represents a phone number from iOS contact
/// {@endtemplate}
class IOSPhoneNumber {
  /// {@macro ios_phone_number}
  const IOSPhoneNumber({
    required this.value,
    this.label,
  });

  /// Phone number value
  final String value;
  
  /// Label for the phone number (home, work, mobile, etc.)
  final String? label;
}

/// {@template ios_email_address}
/// Represents an email address from iOS contact
/// {@endtemplate}
class IOSEmailAddress {
  /// {@macro ios_email_address}
  const IOSEmailAddress({
    required this.value,
    this.label,
  });

  /// Email address value
  final String value;
  
  /// Label for the email address (home, work, etc.)
  final String? label;
}

/// {@template ios_address}
/// Represents a physical address from iOS contact
/// {@endtemplate}
class IOSAddress {
  /// {@macro ios_address}
  const IOSAddress({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.label,
  });

  /// Street address
  final String? street;
  
  /// City
  final String? city;
  
  /// State/Province
  final String? state;
  
  /// ZIP/Postal code
  final String? zipCode;
  
  /// Country
  final String? country;
  
  /// Label for the address (home, work, etc.)
  final String? label;
}

/// {@template ios_message}
/// Represents a message from iOS Messages app
/// {@endtemplate}
class IOSMessage {
  /// {@macro ios_message}
  const IOSMessage({
    required this.rowId,
    required this.text,
    required this.date,
    required this.isFromMe,
    this.handleId,
    this.serviceName,
    this.chatIdentifier,
    this.attachmentPath,
    this.attachmentMimeType,
  });

  /// Creates an [IOSMessage] from iOS backup database row
  factory IOSMessage.fromDatabaseRow(Map<String, dynamic> row) {
    return IOSMessage(
      rowId: row['ROWID'] as int,
      text: row['text'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        ((row['date'] as num).toDouble() / 1000000000).round() * 1000 + 
        DateTime(2001).millisecondsSinceEpoch,
      ),
      isFromMe: (row['is_from_me'] as int) == 1,
      handleId: row['handle_id'] as int?,
      serviceName: row['service'] as String?,
      chatIdentifier: row['chat_identifier'] as String?,
      attachmentPath: row['filename'] as String?,
      attachmentMimeType: row['mime_type'] as String?,
    );
  }

  /// Message row ID
  final int rowId;
  
  /// Message text content
  final String text;
  
  /// Message timestamp
  final DateTime date;
  
  /// Whether the message was sent by the device owner
  final bool isFromMe;
  
  /// Handle ID for sender/recipient
  final int? handleId;
  
  /// Service name (SMS, iMessage, etc.)
  final String? serviceName;
  
  /// Chat identifier
  final String? chatIdentifier;
  
  /// Path to attachment file
  final String? attachmentPath;
  
  /// MIME type of attachment
  final String? attachmentMimeType;

  @override
  String toString() {
    return 'IOSMessage(rowId: $rowId, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}, '
        'date: $date, isFromMe: $isFromMe)';
  }
}

/// {@template ios_media_item}
/// Represents a media item from iOS Photos
/// {@endtemplate}
class IOSMediaItem {
  /// {@macro ios_media_item}
  const IOSMediaItem({
    required this.uuid,
    required this.filename,
    required this.dateCreated,
    this.directory,
    this.mediaType,
    this.mediaSubtype,
    this.pixelWidth,
    this.pixelHeight,
    this.duration,
    this.location,
  });

  /// Creates an [IOSMediaItem] from iOS backup database row
  factory IOSMediaItem.fromDatabaseRow(Map<String, dynamic> row) {
    return IOSMediaItem(
      uuid: row['ZUUID'] as String,
      filename: row['ZFILENAME'] as String? ?? '',
      dateCreated: DateTime.fromMillisecondsSinceEpoch(
        ((row['ZDATECREATED'] as num).toDouble() + 978307200) * 1000,
      ),
      directory: row['ZDIRECTORY'] as String?,
      mediaType: row['ZMEDIATYPE'] as int?,
      mediaSubtype: row['ZMEDIASUBTYPE'] as int?,
      pixelWidth: row['ZPIXELWIDTH'] as int?,
      pixelHeight: row['ZPIXELHEIGHT'] as int?,
      duration: row['ZDURATION'] as double?,
    );
  }

  /// Unique identifier
  final String uuid;
  
  /// Filename of the media
  final String filename;
  
  /// Creation date
  final DateTime dateCreated;
  
  /// Directory path
  final String? directory;
  
  /// Media type (1=photo, 2=video)
  final int? mediaType;
  
  /// Media subtype
  final int? mediaSubtype;
  
  /// Width in pixels
  final int? pixelWidth;
  
  /// Height in pixels
  final int? pixelHeight;
  
  /// Duration for videos
  final double? duration;
  
  /// Geographic location where media was taken
  final IOSLocation? location;

  @override
  String toString() {
    return 'IOSMediaItem(uuid: $uuid, filename: $filename, dateCreated: $dateCreated, '
        'mediaType: $mediaType)';
  }
}

/// {@template ios_location}
/// Represents a geographic location from iOS data
/// {@endtemplate}
class IOSLocation {
  /// {@macro ios_location}
  const IOSLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
    this.horizontalAccuracy,
    this.verticalAccuracy,
  });

  /// Latitude coordinate
  final double latitude;
  
  /// Longitude coordinate
  final double longitude;
  
  /// Altitude in meters
  final double? altitude;
  
  /// Timestamp of location reading
  final DateTime? timestamp;
  
  /// Horizontal accuracy in meters
  final double? horizontalAccuracy;
  
  /// Vertical accuracy in meters
  final double? verticalAccuracy;

  @override
  String toString() {
    return 'IOSLocation(latitude: $latitude, longitude: $longitude, timestamp: $timestamp)';
  }
}

/// {@template ios_backup_info}
/// Information about an iOS backup
/// {@endtemplate}
class IOSBackupInfo {
  /// {@macro ios_backup_info}
  const IOSBackupInfo({
    required this.deviceName,
    required this.displayName,
    required this.lastBackupDate,
    required this.backupPath,
    this.deviceUuid,
    this.productType,
    this.productVersion,
    this.buildVersion,
    this.serialNumber,
    this.isEncrypted = false,
  });

  /// Device name
  final String deviceName;
  
  /// Display name of the backup
  final String displayName;
  
  /// Last backup date
  final DateTime lastBackupDate;
  
  /// Path to backup files
  final String backupPath;
  
  /// Device UUID
  final String? deviceUuid;
  
  /// Product type (iPhone, iPad, etc.)
  final String? productType;
  
  /// iOS version
  final String? productVersion;
  
  /// Build version
  final String? buildVersion;
  
  /// Device serial number
  final String? serialNumber;
  
  /// Whether backup is encrypted
  final bool isEncrypted;

  @override
  String toString() {
    return 'IOSBackupInfo(deviceName: $deviceName, displayName: $displayName, '
        'lastBackupDate: $lastBackupDate, isEncrypted: $isEncrypted)';
  }
}