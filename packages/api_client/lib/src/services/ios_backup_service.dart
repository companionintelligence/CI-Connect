import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

/// {@template ios_backup_service}
/// Service for reading iOS backup files and extracting data
/// {@endtemplate}
class IOSBackupService {
  /// {@macro ios_backup_service}
  const IOSBackupService();

  /// Default iTunes backup directory for macOS
  static String get defaultMacBackupPath => 
      path.join(Platform.environment['HOME']!, 'Library/Application Support/MobileSync/Backup');

  /// Default iTunes backup directory for Windows
  static String get defaultWindowsBackupPath => 
      path.join(Platform.environment['APPDATA']!, 'Apple Computer/MobileSync/Backup');

  /// Gets the default backup directory for the current platform
  static String getDefaultBackupPath() {
    if (Platform.isMacOS) {
      return defaultMacBackupPath;
    } else if (Platform.isWindows) {
      return defaultWindowsBackupPath;
    }
    throw UnsupportedError('iOS backup reading is only supported on macOS and Windows');
  }

  /// Discovers available iOS backups on the system
  Future<List<IOSBackupInfo>> discoverBackups() async {
    final backupPath = getDefaultBackupPath();
    final backupDir = Directory(backupPath);
    
    if (!await backupDir.exists()) {
      return [];
    }

    final backups = <IOSBackupInfo>[];
    
    await for (final entity in backupDir.list()) {
      if (entity is Directory) {
        try {
          final backup = await _readBackupInfo(entity.path);
          if (backup != null) {
            backups.add(backup);
          }
        } catch (e) {
          // Skip invalid backup directories
          continue;
        }
      }
    }
    
    // Sort by last backup date (newest first)
    backups.sort((a, b) => b.lastBackupDate.compareTo(a.lastBackupDate));
    return backups;
  }

  /// Reads backup information from a backup directory
  Future<IOSBackupInfo?> _readBackupInfo(String backupPath) async {
    final infoPath = path.join(backupPath, 'Info.plist');
    final manifestPath = path.join(backupPath, 'Manifest.plist');
    
    if (!await File(infoPath).exists() || !await File(manifestPath).exists()) {
      return null;
    }

    // Note: In a real implementation, you would need to parse plist files
    // For now, we'll extract basic info from the directory structure
    final backupDir = Directory(backupPath);
    final stat = await backupDir.stat();
    
    return IOSBackupInfo(
      deviceName: path.basename(backupPath),
      displayName: 'iOS Device Backup',
      lastBackupDate: stat.modified,
      backupPath: backupPath,
      isEncrypted: await File(path.join(backupPath, 'Manifest.db')).exists(),
    );
  }

  /// Extracts contacts from an iOS backup
  Future<List<IOSContact>> extractContacts(String backupPath) async {
    final contactsDbPath = await _findBackupFile(backupPath, '31bb7ba8914766d4ba40d6dfb6113c8b614be442');
    if (contactsDbPath == null) {
      throw IOSImportException('Contacts database not found in backup');
    }

    final database = await openDatabase(contactsDbPath, readOnly: true);
    
    try {
      final contactRows = await database.query('ABPerson');
      final contacts = <IOSContact>[];
      
      for (final row in contactRows) {
        final contact = IOSContact.fromDatabaseRow(row);
        
        // Get phone numbers for this contact
        final phoneNumbers = await _getPhoneNumbers(database, contact.recordId);
        final emailAddresses = await _getEmailAddresses(database, contact.recordId);
        final addresses = await _getAddresses(database, contact.recordId);
        
        contacts.add(IOSContact(
          recordId: contact.recordId,
          displayName: contact.displayName,
          firstName: contact.firstName,
          lastName: contact.lastName,
          organizationName: contact.organizationName,
          phoneNumbers: phoneNumbers,
          emailAddresses: emailAddresses,
          addresses: addresses,
          note: contact.note,
          createdAt: contact.createdAt,
          modifiedAt: contact.modifiedAt,
        ));
      }
      
      return contacts;
    } finally {
      await database.close();
    }
  }

  /// Extracts messages from an iOS backup
  Future<List<IOSMessage>> extractMessages(String backupPath) async {
    final messagesDbPath = await _findBackupFile(backupPath, '3d0d7e5fb2ce288813306e4d4636395e047a3d28');
    if (messagesDbPath == null) {
      throw IOSImportException('Messages database not found in backup');
    }

    final database = await openDatabase(messagesDbPath, readOnly: true);
    
    try {
      final messageRows = await database.rawQuery('''
        SELECT m.ROWID, m.text, m.date, m.is_from_me, m.handle_id, 
               m.service, c.chat_identifier, a.filename, a.mime_type
        FROM message m
        LEFT JOIN chat_message_join cmj ON m.ROWID = cmj.message_id
        LEFT JOIN chat c ON cmj.chat_id = c.ROWID
        LEFT JOIN message_attachment_join maj ON m.ROWID = maj.message_id
        LEFT JOIN attachment a ON maj.attachment_id = a.ROWID
        ORDER BY m.date DESC
        LIMIT 10000
      ''');
      
      return messageRows.map((row) => IOSMessage.fromDatabaseRow(row)).toList();
    } finally {
      await database.close();
    }
  }

  /// Extracts media items from an iOS backup
  Future<List<IOSMediaItem>> extractMediaItems(String backupPath) async {
    final photosDbPath = await _findBackupFile(backupPath, 'caf30ff41be169b6ae86cfb70e04946745b8bd4e');
    if (photosDbPath == null) {
      throw IOSImportException('Photos database not found in backup');
    }

    final database = await openDatabase(photosDbPath, readOnly: true);
    
    try {
      final mediaRows = await database.query(
        'ZGENERICASSET',
        orderBy: 'ZDATECREATED DESC',
        limit: 5000,
      );
      
      return mediaRows.map((row) => IOSMediaItem.fromDatabaseRow(row)).toList();
    } finally {
      await database.close();
    }
  }

  /// Gets phone numbers for a contact
  Future<List<IOSPhoneNumber>> _getPhoneNumbers(Database database, int contactId) async {
    final phoneRows = await database.rawQuery('''
      SELECT value, label FROM ABMultiValue 
      WHERE record_id = ? AND property = 3
    ''', [contactId]);
    
    return phoneRows.map((row) => IOSPhoneNumber(
      value: row['value'] as String,
      label: row['label'] as String?,
    )).toList();
  }

  /// Gets email addresses for a contact
  Future<List<IOSEmailAddress>> _getEmailAddresses(Database database, int contactId) async {
    final emailRows = await database.rawQuery('''
      SELECT value, label FROM ABMultiValue 
      WHERE record_id = ? AND property = 4
    ''', [contactId]);
    
    return emailRows.map((row) => IOSEmailAddress(
      value: row['value'] as String,
      label: row['label'] as String?,
    )).toList();
  }

  /// Gets addresses for a contact
  Future<List<IOSAddress>> _getAddresses(Database database, int contactId) async {
    final addressRows = await database.rawQuery('''
      SELECT value, label FROM ABMultiValue 
      WHERE record_id = ? AND property = 5
    ''', [contactId]);
    
    return addressRows.map((row) {
      final addressData = row['value'] as String? ?? '';
      // Parse address data (simplified - real implementation would parse plist format)
      return IOSAddress(
        street: addressData.isNotEmpty ? addressData : null,
        label: row['label'] as String?,
      );
    }).toList();
  }

  /// Finds a backup file by its hash in the backup directory
  Future<String?> _findBackupFile(String backupPath, String fileHash) async {
    final filePath = path.join(backupPath, fileHash);
    final file = File(filePath);
    
    if (await file.exists()) {
      return filePath;
    }
    
    // Also check for .db extension
    final dbFilePath = '$filePath.db';
    final dbFile = File(dbFilePath);
    
    if (await dbFile.exists()) {
      return dbFilePath;
    }
    
    return null;
  }
}

/// Exception thrown when iOS import operations fail
class IOSImportException implements Exception {
  /// Creates an [IOSImportException]
  const IOSImportException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'IOSImportException: $message';
}