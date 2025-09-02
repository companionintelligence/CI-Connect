# File Sync Module

The File Sync module provides comprehensive functionality to discover, categorize, and sync all images, videos, and documents from local device storage to the CI-Server.

## Features

- **File Discovery**: Automatically discovers files from device storage directories
- **Permission Management**: Handles storage permissions for Android and iOS
- **File Type Classification**: Supports images, videos, and documents with comprehensive format support
- **CI-Server Integration**: Syncs files to CI-Server content endpoint
- **Progress Tracking**: Real-time progress updates during sync operations
- **Error Handling**: Comprehensive error reporting and recovery

## Supported File Types

### Images
- JPG/JPEG, PNG, GIF, BMP, WebP, HEIC, TIFF

### Videos
- MP4, MOV, AVI, MKV, WebM, M4V, 3GP, WMV

### Documents
- PDF, DOC/DOCX, TXT, RTF, XLS/XLSX, PPT/PPTX

## Usage

```dart
import 'package:app_core/app_core.dart';
import 'package:api_client/api_client.dart';

// Initialize API client with your CI-Server base URL
final apiClient = ApiClient(baseUrl: 'https://your-ci-server.com/api');

// Create file sync service
final fileSyncService = FileSyncService(apiClient: apiClient);

// Request permissions
final hasPermissions = await fileSyncService.requestPermissions();
if (!hasPermissions) {
  // Handle permission denied
  return;
}

// Discover files
final files = await fileSyncService.discoverFiles([
  FileType.image,
  FileType.video,
  FileType.document,
]);

print('Found ${files.length} files to sync');

// Sync files with progress tracking
final result = await fileSyncService.syncFiles(
  files,
  onProgress: (current, total, fileName) {
    print('Syncing $current/$total: $fileName');
  },
);

print('Sync completed: ${result.syncedFiles}/${result.totalFiles} files synced');
print('Success rate: ${result.successRate.toStringAsFixed(1)}%');

if (result.errors.isNotEmpty) {
  print('Errors:');
  for (final error in result.errors) {
    print('  - $error');
  }
}
```

## Architecture

The file sync module consists of several key components:

### FileSyncService
Main service class that orchestrates the file discovery and sync process.

### FileType Enum
Defines supported file types with their extensions and display names.

### SyncResult
Contains the results of a sync operation including success/failure counts and error details.

### CI-Server Integration
Files are uploaded to the `/content/upload` endpoint with metadata including:
- File name and type
- File size and modification date
- Original file path
- MIME type detection

## Platform Support

- **Android**: Accesses external storage directories (DCIM, Pictures, Movies, Download, Documents)
- **iOS**: Accesses application documents directory (Photo library integration requires additional setup)

## Error Handling

The service handles various error scenarios:
- Permission denied
- File access errors  
- Network connectivity issues
- Server errors during upload
- Invalid file formats

All errors are captured in the `SyncResult.errors` list with descriptive messages.

## Dependencies

- `api_client`: CI-Server API integration
- `path_provider`: Platform directory access
- `permission_handler`: Storage permission management
- `path`: File path manipulation
- `dio`: HTTP client (via api_client)