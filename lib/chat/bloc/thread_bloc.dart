import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:companion_connect/chat/bloc/thread_event.dart';
import 'package:companion_connect/chat/bloc/thread_state.dart';
import 'package:companion_connect/chat/models/thread_detail.dart';

/// Thread bloc for managing individual thread state.
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  /// Creates a [ThreadBloc] instance.
  ThreadBloc({
    required this.apiClient,
    required this.appBloc,
  }) : super(const ThreadInitial()) {
    on<LoadThreadDetail>(_onLoadThreadDetail);
    on<SendMessage>(_onSendMessage);
  }

  final ApiClient apiClient;
  final AppBloc appBloc;

  /// Handles the [LoadThreadDetail] event.
  Future<void> _onLoadThreadDetail(
    LoadThreadDetail event,
    Emitter<ThreadState> emit,
  ) async {
    emit(const ThreadLoading());

    // Get the current access token from AppBloc
    final appState = appBloc.state;
    if (appState is! AppAuthenticated) {
      emit(const ThreadError(message: 'User not authenticated'));
      return;
    }

    final accessToken = appState.session.accessToken;

    try {
      final dio = Dio();

      print('=== THREAD API REQUEST ===');
      print('Thread ID: ${event.threadId}');
      print('Access Token: $accessToken');

      // Try different possible endpoints for thread details
      final possibleEndpoints = [
        '${apiClient.ciServerBaseUrl}/threads/${event.threadId}',
        '${apiClient.ciServerBaseUrl}/api/threads/${event.threadId}',
        '${apiClient.ciServerBaseUrl}/chat/threads/${event.threadId}',
        '${apiClient.ciServerBaseUrl}/conversations/${event.threadId}',
        '${apiClient.ciServerBaseUrl}/chats/${event.threadId}',
      ];

      Response<dynamic>? response;
      for (final endpoint in possibleEndpoints) {
        try {
          print('Trying thread endpoint: $endpoint');
          response = await dio.get<dynamic>(
            endpoint,
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              responseType: ResponseType.json,
            ),
          );

          if (response.statusCode == 200) {
            print('Success with thread endpoint: $endpoint');
            break;
          }
        } catch (e) {
          print('Failed with thread endpoint $endpoint: $e');
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        emit(const ThreadError(message: 'Failed to load thread details'));
        return;
      }

      if (response.data != null) {
        final data = response.data!;
        print('=== THREAD API RESPONSE ===');
        print('Response data: $data');
        print('==========================');

        final threadDetail = ThreadDetail.fromJson(
          data as Map<String, dynamic>,
        );

        emit(ThreadLoaded(threadDetail: threadDetail));
      } else {
        emit(const ThreadError(message: 'Failed to load thread details'));
      }
    } on DioException catch (e) {
      print('=== THREAD API ERROR ===');
      print('Error Type: ${e.type}');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Message: ${e.message}');
      print('Response Data: ${e.response?.data}');
      print('========================');

      if (e.response?.statusCode == 401) {
        emit(
          const ThreadError(
            message: 'Authentication failed. Please log in again.',
          ),
        );
      } else if (e.response?.statusCode == 404) {
        emit(
          const ThreadError(
            message: 'Thread not found.',
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        emit(
          const ThreadError(
            message:
                'Connection timeout. Please check your internet connection.',
          ),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        emit(
          const ThreadError(
            message:
                'Unable to connect to server. Please check your internet connection.',
          ),
        );
      } else {
        emit(
          ThreadError(
            message: 'Server error: ${e.response?.statusCode} - ${e.message}',
          ),
        );
      }
    } catch (e) {
      print('=== THREAD UNEXPECTED ERROR ===');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('===============================');
      emit(ThreadError(message: 'Unexpected error: $e'));
    }
  }

  /// Handles the [SendMessage] event.
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ThreadState> emit,
  ) async {
    if (state is! ThreadLoaded) return;

    final currentState = state as ThreadLoaded;
    final threadDetail = currentState.threadDetail;

    // Emit sending message state to show loading in UI
    emit(ThreadSendingMessage(threadDetail: threadDetail));

    // Get the current access token from AppBloc
    final appState = appBloc.state;
    if (appState is! AppAuthenticated) {
      emit(const ThreadError(message: 'User not authenticated'));
      return;
    }

    final accessToken = appState.session.accessToken;

    try {
      final dio = Dio();

      // Get the first available model from the thread or use a default
      final model = threadDetail.model.isNotEmpty
          ? threadDetail.model
          : 'gemma3:1b';

      print('=== SEND MESSAGE API REQUEST ===');
      print('Thread ID: ${threadDetail.id}');
      print('Model: $model');
      print('Prompt: ${event.content}');

      final response = await dio.post<dynamic>(
        '${apiClient.ciServerBaseUrl}/llm/generate',
        data: {
          'prompt': event.content,
          'model': model,
          'threadId': threadDetail.id,
          'enableTools': false,
          'enableThinking': false,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        print('=== SEND MESSAGE API RESPONSE ===');
        print('Response data: $data');
        print('===============================');

        // TODO: Parse the response and add the new message to the thread
        // For now, we'll just refresh the thread to get updated messages
        emit(const ThreadLoading());

        // Reload the thread to get updated messages
        if (accessToken.isNotEmpty) {
          // Create a new Dio instance for the reload
          final dio = Dio();

          // Try different possible endpoints for thread details
          final possibleEndpoints = [
            '${apiClient.ciServerBaseUrl}/threads/${threadDetail.id}',
            '${apiClient.ciServerBaseUrl}/api/threads/${threadDetail.id}',
            '${apiClient.ciServerBaseUrl}/chat/threads/${threadDetail.id}',
            '${apiClient.ciServerBaseUrl}/conversations/${threadDetail.id}',
            '${apiClient.ciServerBaseUrl}/chats/${threadDetail.id}',
          ];

          Response<dynamic>? response;
          for (final endpoint in possibleEndpoints) {
            try {
              print('Reloading thread from: $endpoint');
              response = await dio.get<dynamic>(
                endpoint,
                options: Options(
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                    'Content-Type': 'application/json',
                  },
                  responseType: ResponseType.json,
                ),
              );

              if (response.statusCode == 200) {
                print('Success reloading thread from: $endpoint');
                break;
              }
            } catch (e) {
              print('Failed reloading thread from $endpoint: $e');
              continue;
            }
          }

          if (response != null &&
              response.statusCode == 200 &&
              response.data != null) {
            final data = response.data!;
            print('=== THREAD RELOAD RESPONSE ===');
            print('Response data: $data');
            print('=============================');

            final updatedThreadDetail = ThreadDetail.fromJson(
              data as Map<String, dynamic>,
            );
            emit(ThreadLoaded(threadDetail: updatedThreadDetail));
          } else {
            emit(
              ThreadError(
                message: 'Failed to reload thread after sending message',
              ),
            );
          }
        } else {
          emit(ThreadError(message: 'No access token available for reload'));
        }
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('=== SEND MESSAGE ERROR ===');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('==========================');

      // Emit error state
      emit(ThreadError(message: 'Failed to send message: $e'));
    }
  }
}
