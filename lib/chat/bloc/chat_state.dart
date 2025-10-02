import 'package:companion_connect/chat/models/llm_model.dart';
import 'package:companion_connect/chat/models/thread.dart';

/// Chat state
abstract class ChatState {
  const ChatState();
}

/// Initial chat state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Chat loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Chat loaded state
class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.threads,
    required this.models,
    this.selectedThread,
  });

  final List<Thread> threads;
  final List<LLMModel> models;
  final Thread? selectedThread;
}

/// Chat error state
class ChatError extends ChatState {
  const ChatError({required this.message});
  final String message;
}
