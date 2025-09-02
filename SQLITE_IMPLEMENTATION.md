# SQLite Implementation for CI-Connect

This document describes the comprehensive SQLite implementation for local client storage and API data management in the CI-Connect application.

## Overview

The SQLite implementation provides:
- **Local Data Storage**: Persistent storage for people, contacts, content, calendar events, and notifications
- **API Response Caching**: Intelligent caching of CI-Server API responses for offline access
- **File Sync Tracking**: Complete tracking of file synchronization status with retry capabilities
- **Offline Support**: Full offline functionality with automatic sync when connectivity is restored
- **Data Integrity**: ACID transactions and foreign key constraints ensure data consistency

## Architecture

### Database Layer
```
packages/api_client/src/database/
├── database_provider.dart          # SQLite database initialization and schema management
├── models/
│   ├── cached_entity.dart          # Base class for cached entities
│   ├── sync_record.dart            # Sync operation tracking
│   ├── notification_record.dart    # Local notification storage
│   ├── file_sync_record.dart       # File synchronization tracking
│   └── api_cache_entry.dart        # API response caching
└── dao/
    ├── base_dao.dart               # Base Data Access Object with common operations
    ├── people_dao.dart             # People data access
    ├── contacts_dao.dart           # Contacts data access
    ├── content_dao.dart            # Content data access
    ├── file_sync_dao.dart          # File sync tracking
    ├── notifications_dao.dart      # Notification management
    └── api_cache_dao.dart          # API response caching
```

### Services Layer
```
packages/api_client/src/
├── enhanced_api_client.dart        # API client with integrated caching
├── caching_service.dart            # Centralized caching service
└── sqlite_usage_example.dart       # Complete usage examples

packages/app_core/src/file_sync/
└── enhanced_file_sync_service.dart # File sync with SQLite tracking
```

## Database Schema

### Core Tables

#### people
```sql
CREATE TABLE people (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  created_at TEXT,
  updated_at TEXT,
  synced_at TEXT,
  dirty INTEGER DEFAULT 0
);
```

#### contacts
```sql
CREATE TABLE contacts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  company TEXT,
  notes TEXT,
  created_at TEXT,
  updated_at TEXT,
  synced_at TEXT,
  dirty INTEGER DEFAULT 0
);
```

#### content
```sql
CREATE TABLE content (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  file_path TEXT,
  file_size INTEGER,
  mime_type TEXT,
  description TEXT,
  tags TEXT,
  created_at TEXT,
  updated_at TEXT,
  synced_at TEXT,
  dirty INTEGER DEFAULT 0
);
```

#### file_sync_records
```sql
CREATE TABLE file_sync_records (
  id TEXT PRIMARY KEY,
  file_path TEXT NOT NULL UNIQUE,
  file_name TEXT NOT NULL,
  file_size INTEGER,
  file_type TEXT,
  mime_type TEXT,
  checksum TEXT,
  last_modified TEXT,
  synced_at TEXT,
  sync_status TEXT DEFAULT 'pending',
  error_message TEXT
);
```

#### api_cache
```sql
CREATE TABLE api_cache (
  key TEXT PRIMARY KEY,
  endpoint TEXT NOT NULL,
  data TEXT NOT NULL,
  expires_at TEXT,
  created_at TEXT NOT NULL
);
```

#### notifications
```sql
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT,
  data TEXT,
  read INTEGER DEFAULT 0,
  created_at TEXT,
  updated_at TEXT
);
```

## Key Features

### 1. Automatic API Response Caching

The `EnhancedApiClient` automatically caches API responses with configurable TTL:

```dart
// Cached API call with 1-hour TTL
final people = await apiClient.getPeople();

// Force refresh from server
final freshPeople = await apiClient.getPeople(forceRefresh: true);

// Offline access to cached data
final cachedPeople = await apiClient.getCachedPeople();
```

### 2. File Synchronization Tracking

Complete tracking of file sync operations with retry capabilities:

```dart
// Discover and record files for sync
final recordedCount = await fileSyncService.discoverAndRecordFiles([
  FileType.image,
  FileType.video,
  FileType.document,
]);

// Sync files with progress tracking
final result = await fileSyncService.syncPendingFiles(
  onProgress: (current, total, fileName) {
    print('Syncing $current/$total: $fileName');
  },
);

// Retry failed syncs
await fileSyncService.retryFailedSyncs();
```

### 3. Offline Notification Management

Local storage and management of notifications:

```dart
// Store notification locally
await apiClient.storeNotification(
  'Sync Complete',
  body: 'Files synced successfully',
  type: 'success',
);

// Get unread notifications
final unread = await apiClient.getUnreadNotifications();

// Mark as read
await apiClient.markNotificationAsRead(notificationId);
```

### 4. Intelligent Sync Strategy

The system implements a "dirty flag" strategy for efficient synchronization:

- **Local Changes**: Entities modified locally are marked as "dirty"
- **Background Sync**: Dirty entities are automatically synced when connectivity is available
- **Conflict Resolution**: Last-write-wins strategy with timestamps
- **Retry Logic**: Failed syncs are automatically retried with exponential backoff

### 5. Data Integrity and Performance

- **Indexes**: Optimized indexes for common query patterns
- **Transactions**: ACID transactions ensure data consistency
- **Connection Pooling**: Efficient database connection management
- **Cleanup**: Automatic cleanup of expired cache entries and old sync records

## Usage Examples

### Basic Setup

```dart
// Initialize enhanced API client
final apiClient = EnhancedApiClient(
  ciServerBaseUrl: 'https://your-ci-server.com/api',
);

// Initialize database
await apiClient.initialize();

// Create file sync service
final fileSyncService = EnhancedFileSyncService(
  apiClient: apiClient,
);
```

### Working with Cached Data

```dart
// Fetch with automatic caching
final people = await apiClient.getPeople();

// Offline access
final cachedPeople = await apiClient.getCachedPeople();

// Search cached data
final dao = PeopleDao();
final results = await dao.search('John');
```

### File Synchronization

```dart
// Discover files
await fileSyncService.discoverAndRecordFiles([
  FileType.image,
  FileType.video,
]);

// Sync with progress
final result = await fileSyncService.syncPendingFiles(
  onProgress: (current, total, fileName) {
    updateUI(current, total, fileName);
  },
);
```

### Maintenance Operations

```dart
// Cache maintenance
await apiClient.caching.performMaintenance();

// Get statistics
final stats = await apiClient.getCacheStats();

// Cleanup old data
await fileSyncService.cleanupOldRecords(
  olderThan: Duration(days: 30),
);
```

## CI-Server API Integration

The SQLite implementation integrates seamlessly with all CI-Server endpoints:

- **`/people`** - People management with local caching
- **`/places`** - Places data with offline access
- **`/content`** - Content upload and sync tracking
- **`/contacts`** - Contact synchronization
- **`/things`** - Things/objects management

Each endpoint supports:
- Automatic response caching
- Offline data access
- Optimistic updates with sync
- Conflict resolution

## Testing

Comprehensive test coverage includes:

```dart
// Run SQLite implementation tests
flutter test packages/api_client/test/sqlite_implementation_test.dart
```

Tests cover:
- Database schema validation
- DAO operations (CRUD)
- Caching mechanisms
- File sync tracking
- Notification management
- Data integrity

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Database connections are created on-demand
2. **Batch Operations**: Multiple inserts/updates are batched for efficiency
3. **Index Usage**: Strategic indexes for common query patterns
4. **Cache Expiration**: Automatic cleanup of expired data
5. **Connection Pooling**: Efficient resource management

### Monitoring

The system provides comprehensive monitoring:

```dart
final stats = await apiClient.getCacheStats();
// Returns: cache size, hit rates, sync statistics, etc.
```

## Migration and Backwards Compatibility

The SQLite implementation maintains backwards compatibility with existing APIs:

- All existing method signatures remain unchanged
- Transparent caching layer
- Gradual migration path from Firebase
- Data export/import capabilities

## Error Handling

Robust error handling throughout:

- **Network Failures**: Graceful degradation to cached data
- **Database Errors**: Automatic retry with backoff
- **File Access Issues**: Detailed error reporting
- **Sync Conflicts**: Configurable resolution strategies

## Future Enhancements

Planned improvements:

1. **Multi-device Sync**: Conflict resolution across devices
2. **Partial Sync**: Incremental updates for large datasets
3. **Encryption**: At-rest encryption for sensitive data
4. **Background Sync**: Background processing for large files
5. **Analytics**: Usage pattern analysis and optimization

## Security Considerations

- **Data Encryption**: Option for field-level encryption
- **Access Control**: Database access limited to application
- **Secure Storage**: Sensitive data protected
- **Audit Trail**: Change tracking for compliance

---

This SQLite implementation provides a robust foundation for offline-first functionality in the CI-Connect application, ensuring users have access to their data regardless of network connectivity while maintaining seamless synchronization with the CI-Server when online.