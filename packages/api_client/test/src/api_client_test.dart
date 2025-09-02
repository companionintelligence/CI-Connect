// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:api_client/src/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<Map<String, dynamic>> {}

void main() {
  group('ApiClient', () {
    late MockDio mockDio;
    late ApiClient apiClient;

    setUp(() {
      mockDio = MockDio();
      apiClient = ApiClient(
        httpClient: mockDio,
      );
    });

    test('can be instantiated', () {
      expect(apiClient, isNotNull);
    });

    group('CI Server connectivity', () {
      test('isConnectedToCiServer returns true when server responds with 200', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockDio.get(
              any(),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.isConnectedToCiServer();

        expect(result, isTrue);
        verify(() => mockDio.get(
              'https://api.companion-intelligence.com/health',
              options: any(named: 'options'),
            )).called(1);
      });

      test('isConnectedToCiServer returns false when request fails', () async {
        when(() => mockDio.get(
              any(),
              options: any(named: 'options'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await apiClient.isConnectedToCiServer();

        expect(result, isFalse);
      });

      test('getCiServerStatus returns status data when successful', () async {
        final expectedData = {'status': 'ok', 'version': '1.0.0'};
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(expectedData);
        when(() => mockDio.get(
              any(),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.getCiServerStatus();

        expect(result, equals(expectedData));
        verify(() => mockDio.get(
              'https://api.companion-intelligence.com/api/status',
              options: any(named: 'options'),
            )).called(1);
      });

      test('getCiServerStatus returns null when request fails', () async {
        when(() => mockDio.get(
              any(),
              options: any(named: 'options'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await apiClient.getCiServerStatus();

        expect(result, isNull);
      });

      test('sendDataToCiServer returns true when data sent successfully', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final testData = {'key': 'value'};
        final result = await apiClient.sendDataToCiServer(testData);

        expect(result, isTrue);
        verify(() => mockDio.post(
              'https://api.companion-intelligence.com/api/data',
              data: testData,
              options: any(named: 'options'),
            )).called(1);
      });

      test('sendDataToCiServer returns false when request fails', () async {
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
            ));

        final testData = {'key': 'value'};
        final result = await apiClient.sendDataToCiServer(testData);

        expect(result, isFalse);
      });
    });

    test('uses custom CI server base URL when provided', () async {
      final customApiClient = ApiClient(
        httpClient: mockDio,
        ciServerBaseUrl: 'https://custom-ci-server.com',
      );

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => mockResponse);

      await customApiClient.isConnectedToCiServer();

      verify(() => mockDio.get(
            'https://custom-ci-server.com/health',
            options: any(named: 'options'),
          )).called(1);
    });

    group('People API', () {
      test('getPeople returns list of people when successful', () async {
        final expectedData = [
          {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
          {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
        ];
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(expectedData);
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.getPeople(limit: 10);

        expect(result, equals(expectedData));
        verify(() => mockDio.get(
              'https://api.companion-intelligence.com/api/people',
              queryParameters: {'limit': 10},
              options: any(named: 'options'),
            )).called(1);
      });

      test('createPerson returns created person when successful', () async {
        final personData = {'name': 'John Doe', 'email': 'john@example.com'};
        final expectedResponse = {'id': '1', ...personData};
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn(expectedResponse);
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.createPerson(personData);

        expect(result, equals(expectedResponse));
        verify(() => mockDio.post(
              'https://api.companion-intelligence.com/api/people',
              data: personData,
              options: any(named: 'options'),
            )).called(1);
      });
    });

    group('Places API', () {
      test('getPlaces returns list of places when successful', () async {
        final expectedData = [
          {'id': '1', 'name': 'Office', 'address': '123 Main St'},
          {'id': '2', 'name': 'Home', 'address': '456 Oak Ave'},
        ];
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(expectedData);
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.getPlaces(search: 'office');

        expect(result, equals(expectedData));
        verify(() => mockDio.get(
              'https://api.companion-intelligence.com/api/places',
              queryParameters: {'search': 'office'},
              options: any(named: 'options'),
            )).called(1);
      });

      test('createPlace returns created place when successful', () async {
        final placeData = {'name': 'Office', 'address': '123 Main St'};
        final expectedResponse = {'id': '1', ...placeData};
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn(expectedResponse);
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.createPlace(placeData);

        expect(result, equals(expectedResponse));
      });
    });

    group('Content API', () {
      test('getContent returns list of content when successful', () async {
        final expectedData = [
          {'id': '1', 'title': 'Document 1', 'type': 'document'},
          {'id': '2', 'title': 'Image 1', 'type': 'image'},
        ];
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(expectedData);
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.getContent(type: 'document');

        expect(result, equals(expectedData));
        verify(() => mockDio.get(
              'https://api.companion-intelligence.com/api/content',
              queryParameters: {'type': 'document'},
              options: any(named: 'options'),
            )).called(1);
      });

      test('createContent returns created content when successful', () async {
        final contentData = {'title': 'New Document', 'type': 'document'};
        final expectedResponse = {'id': '1', ...contentData};
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn(expectedResponse);
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.createContent(contentData);

        expect(result, equals(expectedResponse));
      });
    });

    group('Contact API', () {
      test('getContact returns list of contacts when successful', () async {
        final expectedData = [
          {'id': '1', 'name': 'Support', 'email': 'support@example.com'},
        ];
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(expectedData);
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.getContact(limit: 5);

        expect(result, equals(expectedData));
      });

      test('createContact returns created contact when successful', () async {
        final contactData = {'name': 'Support', 'email': 'support@example.com'};
        final expectedResponse = {'id': '1', ...contactData};
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn(expectedResponse);
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.createContact(contactData);

        expect(result, equals(expectedResponse));
      });
    });

    group('Things API', () {
      test('getThings returns list of things when successful', () async {
        final expectedData = [
          {'id': '1', 'name': 'Laptop', 'category': 'electronics'},
          {'id': '2', 'name': 'Phone', 'category': 'electronics'},
        ];
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(expectedData);
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.getThings(category: 'electronics');

        expect(result, equals(expectedData));
        verify(() => mockDio.get(
              'https://api.companion-intelligence.com/api/things',
              queryParameters: {'category': 'electronics'},
              options: any(named: 'options'),
            )).called(1);
      });

      test('createThing returns created thing when successful', () async {
        final thingData = {'name': 'Laptop', 'category': 'electronics'};
        final expectedResponse = {'id': '1', ...thingData};
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn(expectedResponse);
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final result = await apiClient.createThing(thingData);

        expect(result, equals(expectedResponse));
      });
    });

    group('Error handling', () {
      test('returns null when API calls fail', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
            ));

        final peopleResult = await apiClient.getPeople();
        final placesResult = await apiClient.getPlaces();
        final contentResult = await apiClient.getContent();
        final contactResult = await apiClient.getContact();
        final thingsResult = await apiClient.getThings();

        expect(peopleResult, isNull);
        expect(placesResult, isNull);
        expect(contentResult, isNull);
        expect(contactResult, isNull);
        expect(thingsResult, isNull);
      });
    });
  });
}