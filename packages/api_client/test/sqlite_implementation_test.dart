// import 'package:flutter_test/flutter_test.dart';
// import 'package:api_client/api_client.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// void main() {
//   group('SQLite Database Implementation Tests', () {
//     setUp(() {
//       // Initialize FFI for testing
//       sqfliteFfiInit();
//       databaseFactory = databaseFactoryFfi;
//     });

//     tearDown(() async {
//       // Clean up after tests
//       try {
//         await DatabaseProvider.instance.close();
//       } catch (_) {
//         // Database might not be initialized
//       }
//     });

//     test('database initializes correctly', () async {
//       final database = await DatabaseProvider.instance.database;
//       expect(database, isNotNull);
//       expect(database.isOpen, isTrue);
//     });

//     test('people DAO basic operations work', () async {
//       final dao = PeopleDao();
      
//       // Test insert
//       final person = CachedPerson(
//         id: 'test-1',
//         name: 'John Doe',
//         email: 'john@example.com',
//         phone: '+1234567890',
//         createdAt: DateTime.now(),
//       );
      
//       await dao.insert(person);
      
//       // Test get by ID
//       final retrieved = await dao.getById('test-1');
//       expect(retrieved, isNotNull);
//       expect(retrieved!.name, equals('John Doe'));
//       expect(retrieved.email, equals('john@example.com'));
      
//       // Test search
//       final searchResults = await dao.search('John');
//       expect(searchResults.length, equals(1));
//       expect(searchResults.first.name, equals('John Doe'));
      
//       // Test update
//       final updated = person.copyWith(name: 'John Smith');
//       await dao.update(updated);
      
//       final retrievedUpdated = await dao.getById('test-1');
//       expect(retrievedUpdated!.name, equals('John Smith'));
      
//       // Test delete
//       await dao.delete('test-1');
//       final deletedPerson = await dao.getById('test-1');
//       expect(deletedPerson, isNull);
//     });

//     test('contacts DAO basic operations work', () async {
//       final dao = ContactsDao();
      
//       // Test insert
//       final contact = CachedContact(
//         id: 'contact-1',
//         name: 'Jane Smith',
//         email: 'jane@company.com',
//         company: 'Test Company',
//         notes: 'Important contact',
//         createdAt: DateTime.now(),
//       );
      
//       await dao.insert(contact);
      
//       // Test get by ID
//       final retrieved = await dao.getById('contact-1');
//       expect(retrieved, isNotNull);
//       expect(retrieved!.name, equals('Jane Smith'));
//       expect(retrieved.company, equals('Test Company'));
      
//       // Test search by company
//       final companyResults = await dao.getByCompany('Test Company');
//       expect(companyResults.length, equals(1));
//       expect(companyResults.first.name, equals('Jane Smith'));
//     });

//     test('file sync DAO operations work', () async {
//       final dao = FileSyncDao();
      
//       // Test insert
//       final record = FileSyncRecord(
//         id: 'file-1',
//         filePath: '/test/path/image.jpg',
//         fileName: 'image.jpg',
//         fileSize: 1024,
//         fileType: 'image',
//         mimeType: 'image/jpeg',
//         lastModified: DateTime.now(),
//         syncStatus: FileSyncStatus.pending,
//       );
      
//       await dao.insert(record);
      
//       // Test get by ID
//       final retrieved = await dao.getById('file-1');
//       expect(retrieved, isNotNull);
//       expect(retrieved!.fileName, equals('image.jpg'));
//       expect(retrieved.syncStatus, equals(FileSyncStatus.pending));
      
//       // Test get files to sync
//       final toSync = await dao.getFilesToSync();
//       expect(toSync.length, equals(1));
//       expect(toSync.first.fileName, equals('image.jpg'));
      
//       // Test update sync status
//       await dao.updateSyncStatus('file-1', FileSyncStatus.synced);
      
//       final updated = await dao.getById('file-1');
//       expect(updated!.syncStatus, equals(FileSyncStatus.synced));
//       expect(updated.syncedAt, isNotNull);
//     });

//     test('API cache DAO operations work', () async {
//       final dao = ApiCacheDao();
      
//       // Test cache response
//       final testData = {
//         'users': [
//           {'id': '1', 'name': 'User 1'},
//           {'id': '2', 'name': 'User 2'},
//         ]
//       };
      
//       await dao.cacheResponse('/api/users', testData);
      
//       // Test get cached response
//       final cached = await dao.getCachedResponse('/api/users');
//       expect(cached, isNotNull);
//       expect(cached!['users'], isA<List>());
//       expect((cached['users'] as List).length, equals(2));
      
//       // Test has cached data
//       final hasCached = await dao.hasCachedData('/api/users');
//       expect(hasCached, isTrue);
      
//       // Test cache miss
//       final notCached = await dao.getCachedResponse('/api/posts');
//       expect(notCached, isNull);
//     });

//     test('notifications DAO operations work', () async {
//       final dao = NotificationsDao();
      
//       // Test insert
//       final notification = NotificationRecord(
//         id: 'notif-1',
//         title: 'Test Notification',
//         body: 'This is a test notification',
//         type: 'info',
//         createdAt: DateTime.now(),
//       );
      
//       await dao.insert(notification);
      
//       // Test get unread
//       final unread = await dao.getUnread();
//       expect(unread.length, equals(1));
//       expect(unread.first.title, equals('Test Notification'));
      
//       // Test unread count
//       final unreadCount = await dao.getUnreadCount();
//       expect(unreadCount, equals(1));
      
//       // Test mark as read
//       await dao.markAsRead('notif-1');
      
//       final unreadAfter = await dao.getUnread();
//       expect(unreadAfter.length, equals(0));
      
//       final unreadCountAfter = await dao.getUnreadCount();
//       expect(unreadCountAfter, equals(0));
//     });

//     test('caching service integration works', () async {
//       final service = CachingService();
      
//       // Test caching people
//       final people = [
//         Person(
//           id: 'p1',
//           name: 'Alice Johnson',
//           email: 'alice@example.com',
//         ),
//         Person(
//           id: 'p2',
//           name: 'Bob Wilson',
//           email: 'bob@example.com',
//         ),
//       ];
      
//       await service.cachePeople(people);
      
//       // Test getting cached people
//       final cached = await service.getCachedPeople();
//       expect(cached.length, equals(2));
//       expect(cached.any((p) => p.name == 'Alice Johnson'), isTrue);
//       expect(cached.any((p) => p.name == 'Bob Wilson'), isTrue);
      
//       // Test file sync recording
//       await service.recordFileForSync(
//         '/test/image.png',
//         'image.png',
//         fileSize: 2048,
//         fileType: 'image',
//         mimeType: 'image/png',
//       );
      
//       final filesToSync = await service.getFilesToSync();
//       expect(filesToSync.length, equals(1));
//       expect(filesToSync.first.fileName, equals('image.png'));
      
//       // Test notification storage
//       await service.storeNotification(
//         NotificationRecord(
//           id: 'n1',
//           title: 'Sync Complete',
//           body: 'Files have been synced successfully',
//           type: 'success',
//           createdAt: DateTime.now(),
//         ),
//       );
      
//       final notifications = await service.getUnreadNotifications();
//       expect(notifications.length, equals(1));
//       expect(notifications.first.title, equals('Sync Complete'));
//     });
//   });
// }