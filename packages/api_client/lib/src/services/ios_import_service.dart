import 'dart:async';
import 'dart:io';

import '../models/models.dart';
import '../ci_server_client.dart';
import 'ios_backup_service.dart';
import 'ios_import_mapper.dart';

/// {@template ios_import_service}
/// Main service for importing iOS data to CI-Server
/// {@endtemplate}
class IOSImportService {
  /// {@macro ios_import_service}
  IOSImportService({
    required CIServerClient ciServerClient,
    required String studioId,
    IOSBackupService? backupService,
    IOSImportMapper? importMapper,
  }) : _ciServerClient = ciServerClient,
       _studioId = studioId,
       _backupService = backupService ?? const IOSBackupService(),
       _importMapper = importMapper ?? const IOSImportMapper();

  final CIServerClient _ciServerClient;
  final String _studioId;
  final IOSBackupService _backupService;
  final IOSImportMapper _importMapper;

  /// Stream controller for import progress updates
  final _progressController = StreamController<IOSImportProgress>.broadcast();

  /// Stream of import progress updates
  Stream<IOSImportProgress> get progressStream => _progressController.stream;

  /// Discovers available iOS backups on the system
  Future<List<IOSBackupInfo>> discoverBackups() async {
    _emitProgress(IOSImportProgress.discovering());
    
    try {
      final backups = await _backupService.discoverBackups();
      _emitProgress(IOSImportProgress.discovered(backups.length));
      return backups;
    } catch (e) {
      _emitProgress(IOSImportProgress.error('Failed to discover backups: $e'));
      rethrow;
    }
  }

  /// Imports all data from an iOS backup
  Future<IOSImportSummary> importFromBackup(
    IOSBackupInfo backupInfo, {
    IOSImportOptions? options,
  }) async {
    options ??= const IOSImportOptions();
    final startTime = DateTime.now();
    
    _emitProgress(IOSImportProgress.started(backupInfo.deviceName));

    try {
      // Extract data from backup
      final contacts = options.importContacts 
          ? await _extractContacts(backupInfo.backupPath)
          : <IOSContact>[];
      
      final messages = options.importMessages 
          ? await _extractMessages(backupInfo.backupPath)
          : <IOSMessage>[];
      
      final mediaItems = options.importMedia 
          ? await _extractMedia(backupInfo.backupPath)
          : <IOSMediaItem>[];

      // Map and upload to CI-Server
      await _uploadDataToCIServer(contacts, messages, mediaItems, options);

      final endTime = DateTime.now();
      final summary = _importMapper.createImportSummary(
        contacts: contacts,
        messages: messages,
        mediaItems: mediaItems,
        importStartTime: startTime,
        importEndTime: endTime,
      );

      _emitProgress(IOSImportProgress.completed(summary));
      return summary;
    } catch (e) {
      _emitProgress(IOSImportProgress.error('Import failed: $e'));
      rethrow;
    }
  }

  /// Extracts contacts from backup with progress updates
  Future<List<IOSContact>> _extractContacts(String backupPath) async {
    _emitProgress(IOSImportProgress.extracting('contacts'));
    
    try {
      final contacts = await _backupService.extractContacts(backupPath);
      _emitProgress(IOSImportProgress.extracted('contacts', contacts.length));
      return contacts;
    } catch (e) {
      _emitProgress(IOSImportProgress.error('Failed to extract contacts: $e'));
      rethrow;
    }
  }

  /// Extracts messages from backup with progress updates
  Future<List<IOSMessage>> _extractMessages(String backupPath) async {
    _emitProgress(IOSImportProgress.extracting('messages'));
    
    try {
      final messages = await _backupService.extractMessages(backupPath);
      _emitProgress(IOSImportProgress.extracted('messages', messages.length));
      return messages;
    } catch (e) {
      _emitProgress(IOSImportProgress.error('Failed to extract messages: $e'));
      rethrow;
    }
  }

  /// Extracts media from backup with progress updates
  Future<List<IOSMediaItem>> _extractMedia(String backupPath) async {
    _emitProgress(IOSImportProgress.extracting('media'));
    
    try {
      final mediaItems = await _backupService.extractMediaItems(backupPath);
      _emitProgress(IOSImportProgress.extracted('media', mediaItems.length));
      return mediaItems;
    } catch (e) {
      _emitProgress(IOSImportProgress.error('Failed to extract media: $e'));
      rethrow;
    }
  }

  /// Uploads mapped data to CI-Server
  Future<void> _uploadDataToCIServer(
    List<IOSContact> contacts,
    List<IOSMessage> messages, 
    List<IOSMediaItem> mediaItems,
    IOSImportOptions options,
  ) async {
    var uploadedCount = 0;
    var totalItems = 0;

    // Upload contacts as Contact entities
    if (options.importContacts) {
      _emitProgress(IOSImportProgress.uploading('contacts'));
      final ciContacts = _importMapper.mapContactsToCIServer(contacts);
      totalItems += ciContacts.length;
      
      for (final contact in ciContacts) {
        try {
          final contactData = contact.toJson();
          await _ciServerClient.createContact(studioId: _studioId, contactData: contactData);
          uploadedCount++;
          
          if (uploadedCount % 10 == 0) {
            _emitProgress(IOSImportProgress.uploading('contacts', uploadedCount, ciContacts.length));
          }
        } catch (e) {
          // Continue with other contacts if one fails
          continue;
        }
      }
    }

    // Upload contacts as Person entities (if enabled)
    if (options.importContactsAsPersons) {
      _emitProgress(IOSImportProgress.uploading('persons'));
      final ciPersons = _importMapper.mapContactsToPersons(contacts);
      totalItems += ciPersons.length;
      
      for (final person in ciPersons) {
        try {
          final personData = person.toJson();
          await _ciServerClient.createPerson(studioId: _studioId, personData: personData);
          uploadedCount++;
          
          if (uploadedCount % 10 == 0) {
            _emitProgress(IOSImportProgress.uploading('persons', uploadedCount, ciPersons.length));
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Upload messages as Content
    if (options.importMessages) {
      _emitProgress(IOSImportProgress.uploading('messages'));
      final ciContent = _importMapper.mapMessagesToContent(messages);
      totalItems += ciContent.length;
      
      for (final content in ciContent) {
        try {
          final contentData = content.toJson();
          await _ciServerClient.createContent(studioId: _studioId, contentData: contentData);
          uploadedCount++;
          
          if (uploadedCount % 20 == 0) {
            _emitProgress(IOSImportProgress.uploading('messages', uploadedCount, ciContent.length));
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Upload media as Content
    if (options.importMedia) {
      _emitProgress(IOSImportProgress.uploading('media'));
      final ciMediaContent = _importMapper.mapMediaToContent(mediaItems);
      totalItems += ciMediaContent.length;
      
      for (final content in ciMediaContent) {
        try {
          final contentData = content.toJson();
          await _ciServerClient.createContent(studioId: _studioId, contentData: contentData);
          uploadedCount++;
          
          if (uploadedCount % 20 == 0) {
            _emitProgress(IOSImportProgress.uploading('media', uploadedCount, ciMediaContent.length));
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Upload places from addresses
    if (options.importPlaces) {
      _emitProgress(IOSImportProgress.uploading('places'));
      final ciPlaces = _importMapper.mapAddressesToPlaces(contacts);
      totalItems += ciPlaces.length;
      
      for (final place in ciPlaces) {
        try {
          final placeData = place.toJson();
          await _ciServerClient.createPlace(studioId: _studioId, placeData: placeData);
          uploadedCount++;
          
          if (uploadedCount % 5 == 0) {
            _emitProgress(IOSImportProgress.uploading('places', uploadedCount, ciPlaces.length));
          }
        } catch (e) {
          continue;
        }
      }
    }
  }

  /// Emits progress update
  void _emitProgress(IOSImportProgress progress) {
    _progressController.add(progress);
  }

  /// Validates that the current platform supports iOS import
  static void validatePlatform() {
    if (!Platform.isMacOS && !Platform.isWindows) {
      throw UnsupportedError(
        'iOS import is only supported on macOS and Windows platforms',
      );
    }
  }

  /// Disposes resources
  void dispose() {
    _progressController.close();
  }
}

/// {@template ios_import_options}
/// Configuration options for iOS import operation
/// {@endtemplate}
class IOSImportOptions {
  /// {@macro ios_import_options}
  const IOSImportOptions({
    this.importContacts = true,
    this.importContactsAsPersons = false,
    this.importMessages = true,
    this.importMedia = true,
    this.importPlaces = true,
    this.maxMessages = 10000,
    this.maxMediaItems = 5000,
  });

  /// Whether to import contacts as Contact entities
  final bool importContacts;
  
  /// Whether to also import contacts as Person entities
  final bool importContactsAsPersons;
  
  /// Whether to import messages
  final bool importMessages;
  
  /// Whether to import media items
  final bool importMedia;
  
  /// Whether to import places from contact addresses
  final bool importPlaces;
  
  /// Maximum number of messages to import
  final int maxMessages;
  
  /// Maximum number of media items to import
  final int maxMediaItems;
}

/// {@template ios_import_progress}
/// Represents the progress of an iOS import operation
/// {@endtemplate}
class IOSImportProgress {
  /// {@macro ios_import_progress}
  const IOSImportProgress._({
    required this.stage,
    this.message,
    this.current,
    this.total,
    this.error,
  });

  /// Creates a discovering progress update
  factory IOSImportProgress.discovering() => 
      const IOSImportProgress._(stage: IOSImportStage.discovering, message: 'Discovering iOS backups...');

  /// Creates a discovered progress update
  factory IOSImportProgress.discovered(int count) => 
      IOSImportProgress._(stage: IOSImportStage.discovered, message: 'Found $count backup(s)');

  /// Creates a started progress update
  factory IOSImportProgress.started(String deviceName) =>
      IOSImportProgress._(stage: IOSImportStage.started, message: 'Starting import from $deviceName');

  /// Creates an extracting progress update
  factory IOSImportProgress.extracting(String dataType) =>
      IOSImportProgress._(stage: IOSImportStage.extracting, message: 'Extracting $dataType...');

  /// Creates an extracted progress update
  factory IOSImportProgress.extracted(String dataType, int count) =>
      IOSImportProgress._(stage: IOSImportStage.extracted, message: 'Extracted $count $dataType');

  /// Creates an uploading progress update
  factory IOSImportProgress.uploading(String dataType, [int? current, int? total]) =>
      IOSImportProgress._(
        stage: IOSImportStage.uploading, 
        message: current != null && total != null 
            ? 'Uploading $dataType ($current/$total)'
            : 'Uploading $dataType...',
        current: current,
        total: total,
      );

  /// Creates a completed progress update
  factory IOSImportProgress.completed(IOSImportSummary summary) =>
      IOSImportProgress._(
        stage: IOSImportStage.completed, 
        message: 'Import completed successfully',
      );

  /// Creates an error progress update
  factory IOSImportProgress.error(String errorMessage) =>
      IOSImportProgress._(stage: IOSImportStage.error, error: errorMessage);

  /// Current stage of import
  final IOSImportStage stage;
  
  /// Progress message
  final String? message;
  
  /// Current progress count
  final int? current;
  
  /// Total progress count
  final int? total;
  
  /// Error message if stage is error
  final String? error;

  /// Progress percentage (0-100)
  double? get percentage => current != null && total != null && total! > 0
      ? (current! / total!) * 100
      : null;

  @override
  String toString() {
    if (error != null) return 'Error: $error';
    if (current != null && total != null) {
      return '$message (${percentage?.toStringAsFixed(1)}%)';
    }
    return message ?? stage.toString();
  }
}

/// Stages of iOS import process
enum IOSImportStage {
  /// Discovering available backups
  discovering,
  
  /// Discovered backups
  discovered,
  
  /// Import process started
  started,
  
  /// Extracting data from backup
  extracting,
  
  /// Data extracted
  extracted,
  
  /// Uploading data to CI-Server
  uploading,
  
  /// Import completed successfully
  completed,
  
  /// Error occurred
  error,
}