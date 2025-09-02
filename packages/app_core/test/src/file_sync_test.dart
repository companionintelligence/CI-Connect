// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:app_core/app_core.dart';
import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('FileSyncService', () {
    late FileSyncService fileSyncService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      fileSyncService = FileSyncService(apiClient: mockApiClient);
    });

    test('can be instantiated', () {
      expect(fileSyncService, isNotNull);
    });

    test('getSyncStats returns initial stats', () async {
      final stats = await fileSyncService.getSyncStats();
      expect(stats, isA<Map<String, int>>());
      expect(stats['totalSynced'], equals(0));
      expect(stats['lastSyncDuration'], equals(0));
    });

    group('FileType', () {
      test('image extensions include common formats', () {
        final extensions = FileType.image.extensions;
        expect(extensions, contains('.jpg'));
        expect(extensions, contains('.jpeg'));
        expect(extensions, contains('.png'));
        expect(extensions, contains('.gif'));
        expect(extensions, contains('.webp'));
      });

      test('video extensions include common formats', () {
        final extensions = FileType.video.extensions;
        expect(extensions, contains('.mp4'));
        expect(extensions, contains('.mov'));
        expect(extensions, contains('.avi'));
        expect(extensions, contains('.mkv'));
        expect(extensions, contains('.webm'));
      });

      test('document extensions include common formats', () {
        final extensions = FileType.document.extensions;
        expect(extensions, contains('.pdf'));
        expect(extensions, contains('.doc'));
        expect(extensions, contains('.docx'));
        expect(extensions, contains('.txt'));
        expect(extensions, contains('.rtf'));
      });

      test('display names are correct', () {
        expect(FileType.image.displayName, equals('Images'));
        expect(FileType.video.displayName, equals('Videos'));
        expect(FileType.document.displayName, equals('Documents'));
      });
    });

    group('SyncResult', () {
      test('calculates success rate correctly', () {
        final result = SyncResult(
          totalFiles: 10,
          syncedFiles: 8,
          failedFiles: 2,
          errors: ['Error 1', 'Error 2'],
        );
        
        expect(result.successRate, equals(80.0));
        expect(result.isSuccess, isFalse);
      });

      test('returns 100% success rate when no failures', () {
        final result = SyncResult(
          totalFiles: 5,
          syncedFiles: 5,
          failedFiles: 0,
          errors: [],
        );
        
        expect(result.successRate, equals(100.0));
        expect(result.isSuccess, isTrue);
      });

      test('handles zero total files', () {
        final result = SyncResult(
          totalFiles: 0,
          syncedFiles: 0,
          failedFiles: 0,
          errors: [],
        );
        
        expect(result.successRate, equals(0.0));
        expect(result.isSuccess, isTrue);
      });
    });
  });
}