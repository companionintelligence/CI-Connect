import 'package:companion_connect/chat/models/thread.dart';

/// Chat events
abstract class ChatEvent {
  const ChatEvent();
}

/// Load chat data event (models and threads)
class LoadChatData extends ChatEvent {
  const LoadChatData();
}

/// Select thread event
class SelectThread extends ChatEvent {
  const SelectThread({required this.thread});
  final Thread thread;
}
