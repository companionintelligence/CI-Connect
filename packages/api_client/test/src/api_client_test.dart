// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'package:api_client/src/api_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<Map<String, dynamic>> {}

void main() {
  group('ApiClient', () {
    late MockFirebaseFirestore mockFirestore;
    late MockDio mockDio;
    late ApiClient apiClient;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockDio = MockDio();
      apiClient = ApiClient(
        firestore: mockFirestore,
        httpClient: mockDio,
      );

      // Setup default mock for generateId
      when(() => mockFirestore.generateId()).thenReturn('test-id');
    });

    test('can be instantiated', () {
      expect(apiClient, isNotNull);
    });

    test('generateId returns firestore generated ID', () {
      final result = apiClient.generateId();
      expect(result, equals('test-id'));
      verify(() => mockFirestore.generateId()).called(1);
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
        firestore: mockFirestore,
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
  });
}