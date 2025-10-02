import 'dart:io';
import 'package:api_client/api_client.dart' as api_client;
import 'package:app_core/src/file_sync/models/file_type.dart';
import 'package:app_core/src/file_sync/models/sync_result.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for syncing files to CI-Server
class FileSyncService {
  /// Creates a [FileSyncService] instance.
  FileSyncService({required api_client.ApiClient apiClient})
    : _apiClient = apiClient;

  final api_client.ApiClient _apiClient;

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
    return (results[Permission.storage]?.isGranted ?? false) ||
        (results[Permission.manageExternalStorage]?.isGranted ?? false);
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    final storage = await Permission.storage.status;
    final photos = await Permission.photos.status;
    final manageExternal = await Permission.manageExternalStorage.status;

    return storage.isGranted || manageExternal.isGranted || photos.isGranted;
  }

  /// Discover files of specified types on device
  Future<List<File>> discoverFiles(List<FileType> fileTypes) async {
    final files = <File>[];

    try {
      // Get common directories to scan
      final directories = await _getDirectoriesToScan();

      for (final directory in directories) {
        if (await directory.exists()) {
          await _scanDirectory(directory, fileTypes, files);
        }
      }
    } catch (e) {
      throw Exception('Failed to discover files: $e');
    }

    return files;
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
    } catch (e) {
      // Fallback to application documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      directories.add(documentsDir);
    }

    return directories;
  }

  /// Recursively scan directory for files matching specified types
  Future<void> _scanDirectory(
    Directory directory,
    List<FileType> fileTypes,
    List<File> files,
  ) async {
    try {
      final entities = await directory.list(recursive: true).toList();

      for (final entity in entities) {
        if (entity is File) {
          final fileType = _getFileType(entity.path);
          if (fileType != null && fileTypes.contains(fileType)) {
            files.add(entity);
          }
        }
      }
    } catch (e) {
      // Skip directories that can't be accessed
    }
  }

  /// Determine file type based on extension
  FileType? _getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    for (final type in FileType.values) {
      if (type.extensions.contains(extension)) {
        return type;
      }
    }

    return null;
  }

  /// Sync discovered files to CI-Server
  Future<SyncResult> syncFiles(
    List<File> files, {
    void Function(int current, int total, String fileName)? onProgress,
  }) async {
    final result = SyncResult(
      totalFiles: files.length,
      syncedFiles: 0,
      failedFiles: 0,
      errors: [],
    );

    for (var i = 0; i < files.length; i++) {
      final file = files[i];

      try {
        onProgress?.call(i + 1, files.length, path.basename(file.path));

        await _syncSingleFile(file);
        result.syncedFiles++;
      } catch (e) {
        result.failedFiles++;
        result.errors.add('Failed to sync ${file.path}: $e');
      }
    }

    return result;
  }

  /// Sync a single file to CI-Server
  Future<void> _syncSingleFile(File file) async {
    final fileName = path.basename(file.path);
    final fileType = _getFileType(file.path);
    final fileStat = await file.stat();

    final metadata = {
      'name': fileName,
      'type': fileType?.name ?? 'unknown',
      'size': fileStat.size,
      'modified': fileStat.modified.toIso8601String(),
      'path': file.path,
    };

    // Upload file to content endpoint
    await _apiClient.uploadContent(file.path, metadata);
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    // This could be implemented to track sync history
    // For now, return basic stats
    return {
      'totalSynced': 0,
      'lastSyncDuration': 0,
    };
  }
}
