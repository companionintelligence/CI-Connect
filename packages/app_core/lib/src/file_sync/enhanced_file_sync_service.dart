import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:app_core/src/file_sync/models/file_type.dart';
import 'package:app_core/src/file_sync/models/sync_result.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enhanced service for syncing files to CI-Server with SQLite tracking
class EnhancedFileSyncService {
  /// Creates an [EnhancedFileSyncService] instance.
  EnhancedFileSyncService({
    required EnhancedApiClient apiClient,
  }) : _apiClient = apiClient;

  final EnhancedApiClient _apiClient;

  /// Request necessary permissions for file access
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.photos,
      Permission.videos,
      Permission.manageExternalStorage,
    ];

    final results = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      results[permission] = await permission.request();
    }

    // Return true if at least storage permission is granted
    return results[Permission.storage]?.isGranted == true ||
        results[Permission.manageExternalStorage]?.isGranted == true;
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    final storage = await Permission.storage.status;
    final photos = await Permission.photos.status;
    final manageExternal = await Permission.manageExternalStorage.status;

    return storage.isGranted || manageExternal.isGranted || photos.isGranted;
  }

  /// Discover and record files for sync
  Future<int> discoverAndRecordFiles(List<FileType> fileTypes) async {
    final files = <File>[];
    
    try {
      // Get common directories to scan
      final directories = await _getDirectoriesToScan();
      
      for (final directory in directories) {
        if (await directory.exists()) {
          await _scanDirectory(directory, fileTypes, files);
        }
      }

      // Record discovered files in SQLite
      int recordedCount = 0;
      for (final file in files) {
        try {
          final fileStat = await file.stat();
          final fileName = path.basename(file.path);
          final fileType = _getFileType(file.path);
          
          // Check if file is already recorded
          final existingRecord = await _apiClient.caching
              .getFilesToSync()
              .then((records) => records.where((r) => r.filePath == file.path).firstOrNull);
          
          if (existingRecord == null) {
            await _apiClient.recordFileForSync(
              file.path,
              fileName,
              fileSize: fileStat.size,
              fileType: fileType?.name,
              mimeType: _getMimeType(file.path),
              lastModified: fileStat.modified,
            );
            recordedCount++;
          }
        } catch (e) {
          // Skip files that can't be processed
          continue;
        }
      }
      
      return recordedCount;
    } catch (e) {
      throw Exception('Failed to discover files: $e');
    }
  }

  /// Sync files that are pending in the database
  Future<SyncResult> syncPendingFiles({
    Function(int current, int total, String fileName)? onProgress,
  }) async {
    final pendingFiles = await _apiClient.getFilesToSync();
    
    if (pendingFiles.isEmpty) {
      return SyncResult(
        totalFiles: 0,
        syncedFiles: 0,
        skippedFiles: 0,
        failedFiles: 0,
        errors: [],
      );
    }

    int syncedCount = 0;
    int skippedCount = 0;
    int failedCount = 0;
    final errors = <String>[];

    for (int i = 0; i < pendingFiles.length; i++) {
      final record = pendingFiles[i];
      
      onProgress?.call(i + 1, pendingFiles.length, record.fileName);
      
      try {
        // Update status to syncing
        await _apiClient.caching.updateFileSyncStatus(
          record.id,
          FileSyncStatus.syncing,
        );

        // Check if file still exists
        final file = File(record.filePath);
        if (!await file.exists()) {
          await _apiClient.caching.updateFileSyncStatus(
            record.id,
            FileSyncStatus.failed,
            errorMessage: 'File no longer exists',
          );
          failedCount++;
          errors.add('File not found: ${record.fileName}');
          continue;
        }

        // Upload the file
        final metadata = {
          'syncId': record.id,
          'name': record.fileName,
          'type': record.fileType ?? 'unknown',
          'size': record.fileSize ?? 0,
          'modified': record.lastModified?.toIso8601String(),
          'path': record.filePath,
        };

        await _apiClient.uploadContent(record.filePath, metadata);
        syncedCount++;
        
      } catch (e) {
        await _apiClient.caching.updateFileSyncStatus(
          record.id,
          FileSyncStatus.failed,
          errorMessage: e.toString(),
        );
        failedCount++;
        errors.add('Failed to sync ${record.fileName}: $e');
      }
    }

    return SyncResult(
      totalFiles: pendingFiles.length,
      syncedFiles: syncedCount,
      skippedFiles: skippedCount,
      failedFiles: failedCount,
      errors: errors,
    );
  }

  /// Get sync statistics from database
  Future<Map<String, int>> getSyncStats() async {
    final stats = await _apiClient.getCacheStats();
    return stats['file_sync'] as Map<String, int>? ?? <String, int>{};
  }

  /// Reset failed syncs for retry
  Future<int> retryFailedSyncs() async {
    final fileSyncDao = FileSyncDao();
    return fileSyncDao.resetFailedSyncs();
  }

  /// Remove old sync records
  Future<int> cleanupOldRecords({Duration? olderThan}) async {
    final fileSyncDao = FileSyncDao();
    return fileSyncDao.removeOldRecords(olderThan: olderThan);
  }

  /// Get list of directories to scan for files
  Future<List<Directory>> _getDirectoriesToScan() async {
    final directories = <Directory>[];
    
    try {
      // External storage directories
      if (Platform.isAndroid) {
        final external = await getExternalStorageDirectory();
        if (external != null) {
          directories.add(Directory('${external.path}/DCIM'));
          directories.add(Directory('${external.path}/Pictures'));
          directories.add(Directory('${external.path}/Movies'));
          directories.add(Directory('${external.path}/Download'));
          directories.add(Directory('${external.path}/Documents'));
        }
        
        // Try to access shared storage directories
        directories.addAll([
          Directory('/storage/emulated/0/DCIM'),
          Directory('/storage/emulated/0/Pictures'),
          Directory('/storage/emulated/0/Movies'),
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/Documents'),
        ]);
      }
      
      if (Platform.isIOS) {
        final documentsDir = await getApplicationDocumentsDirectory();
        directories.add(documentsDir);
        
        // iOS Photos library would require photo_manager plugin
        // For now, focus on documents directory
      }
      
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        final documentsDir = await getApplicationDocumentsDirectory();
        directories.add(documentsDir);
        
        // Add common user directories
        final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
        if (homeDir != null) {
          directories.addAll([
            Directory('$homeDir/Documents'),
            Directory('$homeDir/Pictures'),
            Directory('$homeDir/Downloads'),
            Directory('$homeDir/Desktop'),
          ]);
        }
      }
    } catch (e) {
      // If we can't get standard directories, fall back to app documents
      try {
        final documentsDir = await getApplicationDocumentsDirectory();
        directories.add(documentsDir);
      } catch (_) {
        // Can't even get app documents directory
      }
    }
    
    return directories;
  }

  /// Recursively scan directory for files
  Future<void> _scanDirectory(
    Directory directory,
    List<FileType> fileTypes,
    List<File> files,
  ) async {
    try {
      final entities = directory.listSync(recursive: false);
      
      for (final entity in entities) {
        if (entity is File) {
          final fileType = _getFileType(entity.path);
          if (fileType != null && fileTypes.contains(fileType)) {
            files.add(entity);
          }
        } else if (entity is Directory) {
          // Recursively scan subdirectories (with depth limit)
          if (_shouldScanSubdirectory(entity.path)) {
            await _scanDirectory(entity, fileTypes, files);
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
  }

  /// Check if we should scan a subdirectory
  bool _shouldScanSubdirectory(String dirPath) {
    final dirName = path.basename(dirPath).toLowerCase();
    
    // Skip hidden directories and system directories
    if (dirName.startsWith('.') || 
        dirName == 'android' || 
        dirName == 'cache' ||
        dirName == 'temp' ||
        dirName == 'tmp') {
      return false;
    }
    
    return true;
  }

  /// Get file type based on extension
  FileType? _getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    for (final fileType in FileType.values) {
      if (fileType.extensions.contains(extension)) {
        return fileType;
      }
    }
    
    return null;
  }

  /// Get MIME type based on file extension
  String? _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    // Common MIME types mapping
    const mimeTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.bmp': 'image/bmp',
      '.webp': 'image/webp',
      '.heic': 'image/heic',
      '.tiff': 'image/tiff',
      '.mp4': 'video/mp4',
      '.mov': 'video/quicktime',
      '.avi': 'video/x-msvideo',
      '.mkv': 'video/x-matroska',
      '.webm': 'video/webm',
      '.m4v': 'video/x-m4v',
      '.3gp': 'video/3gpp',
      '.wmv': 'video/x-ms-wmv',
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.txt': 'text/plain',
      '.rtf': 'application/rtf',
      '.xls': 'application/vnd.ms-excel',
      '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '.ppt': 'application/vnd.ms-powerpoint',
      '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    };
    
    return mimeTypes[extension];
  }
}