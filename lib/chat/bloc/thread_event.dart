/// Base class for all thread events.
abstract class ThreadEvent {
  /// @nodoc
  const ThreadEvent();
}

/// Event to load thread details with messages.
class LoadThreadDetail extends ThreadEvent {
  /// @nodoc
  const LoadThreadDetail({
    required this.threadId,
  });

  /// The thread ID to load.
  final String threadId;
}

/// Event to send a new message to the thread.
class SendMessage extends ThreadEvent {
  /// @nodoc
  const SendMessage({
    required this.content,
  });

  /// The content of the message to send.
  final String content;
}
