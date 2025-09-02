import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  group('CIServerApiClient', () {
    late MockDio mockDio;
    late CIServerApiClient client;

    setUp(() {
      mockDio = MockDio();
      client = CIServerApiClient(
        baseUrl: 'https://api.test.com',
        dio: mockDio,
      );
    });

    group('getAll', () {
      test('returns list from direct array response', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn([
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ]);
        when(() => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        final result = await client.getAll('test-endpoint');

        expect(result, hasLength(2));
        expect(result[0]['id'], equals('1'));
        expect(result[1]['id'], equals('2'));
        verify(() => mockDio.get('test-endpoint', queryParameters: null)).called(1);
      });

      test('returns list from wrapped data response', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'data': [
            {'id': '1', 'name': 'Item 1'},
            {'id': '2', 'name': 'Item 2'},
          ],
        });
        when(() => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        final result = await client.getAll('test-endpoint');

        expect(result, hasLength(2));
        expect(result[0]['id'], equals('1'));
        expect(result[1]['id'], equals('2'));
      });

      test('returns single item as list when response is Map', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'id': '1',
          'name': 'Single Item',
        });
        when(() => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        final result = await client.getAll('test-endpoint');

        expect(result, hasLength(1));
        expect(result[0]['id'], equals('1'));
        expect(result[0]['name'], equals('Single Item'));
      });

      test('passes query parameters', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn([]);
        when(() => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        final queryParams = {'studio_id': 'test-studio'};
        await client.getAll('test-endpoint', queryParameters: queryParams);

        verify(() => mockDio.get('test-endpoint', queryParameters: queryParams)).called(1);
      });

      test('throws CIServerApiException on DioException', () async {
        when(() => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          message: 'Network error',
        ));

        expect(
          () async => await client.getAll('test-endpoint'),
          throwsA(isA<CIServerApiException>()),
        );
      });
    });

    group('getById', () {
      test('returns Map from response', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'id': '1',
          'name': 'Test Item',
        });
        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        final result = await client.getById('test-endpoint', '1');

        expect(result['id'], equals('1'));
        expect(result['name'], equals('Test Item'));
        verify(() => mockDio.get('test-endpoint/1')).called(1);
      });

      test('throws CIServerApiException on invalid response format', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn(['invalid', 'format']);
        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        expect(
          () async => await client.getById('test-endpoint', '1'),
          throwsA(isA<CIServerApiException>()),
        );
      });

      test('throws CIServerApiException on DioException', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          message: 'Network error',
        ));

        expect(
          () async => await client.getById('test-endpoint', '1'),
          throwsA(isA<CIServerApiException>()),
        );
      });
    });

    group('create', () {
      test('creates item and returns response', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'id': '1',
          'name': 'Created Item',
        });
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse);

        final data = {'name': 'New Item'};
        final result = await client.create('test-endpoint', data);

        expect(result['id'], equals('1'));
        expect(result['name'], equals('Created Item'));
        verify(() => mockDio.post('test-endpoint', data: data)).called(1);
      });

      test('throws CIServerApiException on DioException', () async {
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          message: 'Network error',
        ));

        final data = {'name': 'New Item'};
        expect(
          () async => await client.create('test-endpoint', data),
          throwsA(isA<CIServerApiException>()),
        );
      });
    });

    group('update', () {
      test('updates item and returns response', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.data).thenReturn({
          'id': '1',
          'name': 'Updated Item',
        });
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse);

        final data = {'name': 'Updated Item'};
        final result = await client.update('test-endpoint', '1', data);

        expect(result['id'], equals('1'));
        expect(result['name'], equals('Updated Item'));
        verify(() => mockDio.put('test-endpoint/1', data: data)).called(1);
      });

      test('throws CIServerApiException on DioException', () async {
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          message: 'Network error',
        ));

        final data = {'name': 'Updated Item'};
        expect(
          () async => await client.update('test-endpoint', '1', data),
          throwsA(isA<CIServerApiException>()),
        );
      });
    });

    group('delete', () {
      test('deletes item successfully', () async {
        final mockResponse = MockResponse();
        when(() => mockDio.delete(any())).thenAnswer((_) async => mockResponse);

        await client.delete('test-endpoint', '1');

        verify(() => mockDio.delete('test-endpoint/1')).called(1);
      });

      test('throws CIServerApiException on DioException', () async {
        when(() => mockDio.delete(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/test'),
          message: 'Network error',
        ));

        expect(
          () async => await client.delete('test-endpoint', '1'),
          throwsA(isA<CIServerApiException>()),
        );
      });
    });

    group('dispose', () {
      test('closes dio client', () {
        when(() => mockDio.close()).thenAnswer((_) async {});

        client.dispose();

        verify(() => mockDio.close()).called(1);
      });
    });

    test('sets correct headers and base URL', () {
      final options = mockDio.options;
      expect(options.baseUrl, equals('https://api.test.com'));
      expect(options.headers['Content-Type'], equals('application/json'));
      expect(options.headers['Accept'], equals('application/json'));
    });
  });

  group('CIServerApiException', () {
    test('toString returns formatted message', () {
      const exception = CIServerApiException('Test error');
      expect(exception.toString(), equals('CIServerApiException: Test error'));
    });

    test('stores cause when provided', () {
      final cause = Exception('Root cause');
      final exception = CIServerApiException('Test error', cause);
      expect(exception.cause, equals(cause));
    });
  });
}