import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:companion_connect/chat/bloc/chat_event.dart';
import 'package:companion_connect/chat/bloc/chat_state.dart';
import 'package:companion_connect/chat/models/llm_model.dart';
import 'package:companion_connect/chat/models/thread.dart';

/// Chat bloc for managing chat state
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  /// Creates a [ChatBloc] instance.
  ChatBloc({
    required this.apiClient,
    required this.appBloc,
  }) : super(const ChatInitial()) {
    on<LoadChatData>(_onLoadChatData);
    on<SelectThread>(_onSelectThread);
  }

  final ApiClient apiClient;
  final AppBloc appBloc;

  /// Handles load chat data event
  Future<void> _onLoadChatData(
    LoadChatData event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Get the current access token from AppBloc
    final appState = appBloc.state;
    if (appState is! AppAuthenticated) {
      emit(const ChatError(message: 'User not authenticated'));
      return;
    }

    final accessToken = appState.session.accessToken;

    try {
      // Create a new Dio instance for the requests
      final dio = Dio();

      // DEBUG: Print request details
      print('=== CHAT API REQUESTS ===');
      print('Models URL: ${apiClient.ciServerBaseUrl}/llm/models');
      print('Threads URL: ${apiClient.ciServerBaseUrl}/api/threads');
      print('Access Token: $accessToken');
      print('========================');

      // Make both requests in parallel
      final futures = await Future.wait([
        _fetchModels(dio, accessToken),
        _fetchThreads(dio, accessToken),
      ]);

      final models = futures[0] as List<LLMModel>;
      final threads = futures[1] as List<Thread>;

      print('=== CHAT API RESPONSE ===');
      print('Models count: ${models.length}');
      print('Threads count: ${threads.length}');
      if (threads.isNotEmpty) {
        print('First thread: ${threads.first.name}');
      }
      print('=========================');

      emit(
        ChatLoaded(
          threads: threads,
          models: models,
          selectedThread: threads.isNotEmpty ? threads.first : null,
        ),
      );
    } on DioException catch (e) {
      print('=== CHAT API ERROR ===');
      print('Error Type: ${e.type}');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Message: ${e.message}');
      print('Response Data: ${e.response?.data}');
      print('======================');

      if (e.response?.statusCode == 401) {
        emit(
          const ChatError(
            message: 'Authentication failed. Please log in again.',
          ),
        );
      } else if (e.response?.statusCode == 403) {
        emit(
          const ChatError(
            message:
                'Access denied. You don\'t have permission to view chat data.',
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        emit(
          const ChatError(
            message:
                'Connection timeout. Please check your internet connection.',
          ),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        emit(
          const ChatError(
            message:
                'Unable to connect to server. Please check your internet connection.',
          ),
        );
      } else {
        emit(
          ChatError(
            message: 'Server error: ${e.response?.statusCode} - ${e.message}',
          ),
        );
      }
    } catch (e) {
      print('=== CHAT UNEXPECTED ERROR ===');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('=============================');
      emit(ChatError(message: 'Unexpected error: $e'));
    }
  }

  /// Handles select thread event
  void _onSelectThread(
    SelectThread event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(
        ChatLoaded(
          threads: currentState.threads,
          models: currentState.models,
          selectedThread: event.thread,
        ),
      );
    }
  }

  /// Fetches available LLM models
  Future<List<LLMModel>> _fetchModels(Dio dio, String accessToken) async {
    // Try different possible endpoints
    final possibleEndpoints = [
      '${apiClient.ciServerBaseUrl}/llm/models',
      '${apiClient.ciServerBaseUrl}/api/llm/models',
      '${apiClient.ciServerBaseUrl}/models',
      '${apiClient.ciServerBaseUrl}/api/models',
    ];

    for (final endpoint in possibleEndpoints) {
      try {
        print('Trying models endpoint: $endpoint');
        final response = await dio.get<dynamic>(
          endpoint,
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
          print('Success with models endpoint: $endpoint');
          print('Models response data: $data');
          if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(LLMModel.fromJson)
                .toList();
          }
        }
      } catch (e) {
        print('Failed with models endpoint $endpoint: $e');
        continue;
      }
    }

    print('All model endpoints failed, returning empty list');
    return <LLMModel>[];
  }

  /// Fetches chat threads
  Future<List<Thread>> _fetchThreads(Dio dio, String accessToken) async {
    // Try different possible endpoints
    final possibleEndpoints = [
      '${apiClient.ciServerBaseUrl}/threads',
      '${apiClient.ciServerBaseUrl}/api/threads',
      '${apiClient.ciServerBaseUrl}/chat/threads',
      '${apiClient.ciServerBaseUrl}/conversations',
      '${apiClient.ciServerBaseUrl}/chats',
    ];

    for (final endpoint in possibleEndpoints) {
      try {
        print('Trying endpoint: $endpoint');
        final response = await dio.get<dynamic>(
          endpoint,
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
          print('Success with endpoint: $endpoint');
          print('Response data: $data');
          if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(Thread.fromJson)
                .toList();
          }
        }
      } catch (e) {
        print('Failed with endpoint $endpoint: $e');
        continue;
      }
    }

    print('All thread endpoints failed, returning empty list');
    return <Thread>[];
  }
}
