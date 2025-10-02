import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:companion_connect/insights/bloc/insights_event.dart';
import 'package:companion_connect/insights/bloc/insights_state.dart';
import 'package:companion_connect/insights/models/insight.dart';

/// Insights bloc
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  /// Creates an [InsightsBloc] instance.
  InsightsBloc({
    required this.apiClient,
  }) : super(const InsightsInitial()) {
    on<LoadInsights>(_onLoadInsights);
  }

  final ApiClient apiClient;

  /// Handles load insights event
  Future<void> _onLoadInsights(
    LoadInsights event,
    Emitter<InsightsState> emit,
  ) async {
    emit(const InsightsLoading());

    try {
      // Create a new Dio instance for the request
      final dio = Dio();

      // DEBUG: Print request details
      print('=== INSIGHTS API REQUEST ===');
      print('URL: ${apiClient.ciServerBaseUrl}/answers');
      print('Access Token: ${event.accessToken}');
      print('Token Length: ${event.accessToken.length}');
      print('Authorization Header: Bearer ${event.accessToken}');
      print('============================');

      // Make GET request to /answers endpoint with authorization header
      Response<dynamic> response;
      try {
        response = await dio.get(
          '${apiClient.ciServerBaseUrl}/answers',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${event.accessToken}',
              'Content-Type': 'application/json',
            },
            responseType: ResponseType.json,
          ),
        );
      } catch (e) {
        print('=== DIO REQUEST ERROR ===');
        print('Error: $e');
        print('Error Type: ${e.runtimeType}');
        print('=========================');
        rethrow;
      }

      // DEBUG: Print the full response details
      print('=== INSIGHTS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Data: ${response.data}');
      print('Response Data Type: ${response.data.runtimeType}');
      print(
        'Response Data Length: ${response.data is List ? response.data.length : 'Not a list'}',
      );
      print('=============================');

      if (response.statusCode == 200 && response.data != null) {
        // Parse the response data
        final data = response.data;

        var insights = <Insight>[];

        // Handle different response formats
        if (data is List) {
          // Direct array response
          print(
            'Processing direct array response with ${data.length} items',
          );
          try {
            insights = data
                .whereType<Map<String, dynamic>>()
                .map(Insight.fromJson)
                .toList();
            print('Successfully parsed ${insights.length} insights');
          } catch (e) {
            print('Error parsing insights array: $e');
            emit(InsightsError(message: 'Failed to parse insights data: $e'));
            return;
          }
        } else if (data is Map<String, dynamic>) {
          // Object response
          if (data.containsKey('answers')) {
            // If response has 'answers' key
            final answers = data['answers'];
            print(
              'Found answers key with ${answers is List ? answers.length : 'non-list'} items',
            );
            if (answers is List) {
              try {
                insights = answers
                    .whereType<Map<String, dynamic>>()
                    .map(
                      Insight.fromJson,
                    )
                    .toList();
                print('Parsed ${insights.length} insights from answers array');
              } catch (e) {
                print('Error parsing answers array: $e');
                emit(
                  InsightsError(message: 'Failed to parse answers data: $e'),
                );
                return;
              }
            }
          } else if (data.containsKey('data')) {
            // If response has 'data' key
            final responseData = data['data'];
            print(
              'Found data key with ${responseData is List ? responseData.length : 'non-list'} items',
            );
            if (responseData is List) {
              try {
                insights = responseData
                    .whereType<Map<String, dynamic>>()
                    .map(
                      Insight.fromJson,
                    )
                    .toList();
                print('Parsed ${insights.length} insights from data array');
              } catch (e) {
                print('Error parsing data array: $e');
                emit(InsightsError(message: 'Failed to parse data: $e'));
                return;
              }
            }
          } else {
            // If response is a single object, wrap it in a list
            try {
              insights = [Insight.fromJson(data)];
              print('Wrapped single object into insights list');
            } catch (e) {
              print('Error parsing single object: $e');
              emit(
                InsightsError(message: 'Failed to parse single insight: $e'),
              );
              return;
            }
          }
        } else {
          print('Unknown response format: ${data.runtimeType}');
          emit(const InsightsError(message: 'Unknown response format'));
          return;
        }

        print('Final insights count: ${insights.length}');
        if (insights.isNotEmpty) {
          print('First insight: ${insights.first}');
        }

        emit(InsightsLoaded(insights: insights));
      } else {
        emit(const InsightsError(message: 'Failed to load insights'));
      }
    } on DioException catch (e) {
      print('=== INSIGHTS API ERROR ===');
      print('Error Type: ${e.type}');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Message: ${e.message}');
      print('Response Data: ${e.response?.data}');
      print('Response Data Type: ${e.response?.data.runtimeType}');
      print('Request URL: ${e.requestOptions.uri}');
      print('Request Headers: ${e.requestOptions.headers}');
      print('Error Details: $e');
      print('========================');

      if (e.response?.statusCode == 401) {
        emit(
          const InsightsError(
            message: 'Authentication failed. Please log in again.',
          ),
        );
      } else if (e.response?.statusCode == 403) {
        emit(
          const InsightsError(
            message:
                "Access denied. You don't have permission to view insights.",
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        emit(
          const InsightsError(
            message:
                'Connection timeout. Please check your internet connection.',
          ),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        emit(
          const InsightsError(
            message:
                'Unable to connect to server. Please check your internet connection.',
          ),
        );
      } else {
        emit(
          InsightsError(
            message: 'Server error: ${e.response?.statusCode} - ${e.message}',
          ),
        );
      }
    } catch (e) {
      print('=== INSIGHTS UNEXPECTED ERROR ===');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('=================================');
      emit(InsightsError(message: 'Unexpected error: $e'));
    }
  }
}
