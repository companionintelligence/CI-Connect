import 'package:companion_connect/chat/models/thread_detail.dart';
import 'package:equatable/equatable.dart';

/// Base class for all thread states.
abstract class ThreadState extends Equatable {
  /// @nodoc
  const ThreadState();
}

/// Initial state of the thread feature.
class ThreadInitial extends ThreadState {
  /// @nodoc
  const ThreadInitial();

  @override
  List<Object> get props => [];
}

/// State indicating that thread data is being loaded.
class ThreadLoading extends ThreadState {
  /// @nodoc
  const ThreadLoading();

  @override
  List<Object> get props => [];
}

/// State indicating that a message is being sent.
class ThreadSendingMessage extends ThreadState {
  /// @nodoc
  const ThreadSendingMessage({required this.threadDetail});

  /// The current thread details.
  final ThreadDetail threadDetail;

  @override
  List<Object> get props => [threadDetail];

  String toString() =>
      'ThreadSendingMessage(threadDetail: ${threadDetail.name})';
}

/// State indicating that thread data has been successfully loaded.
class ThreadLoaded extends ThreadState {
  /// @nodoc
  const ThreadLoaded({
    required this.threadDetail,
  });

  /// The thread details with messages.
  final ThreadDetail threadDetail;

  @override
  List<Object> get props => [threadDetail];

  /// Creates a copy of this state with the given fields replaced.
  ThreadLoaded copyWith({
    ThreadDetail? threadDetail,
  }) {
    return ThreadLoaded(
      threadDetail: threadDetail ?? this.threadDetail,
    );
  }

  @override
  String toString() {
    return 'ThreadLoaded(threadDetail: ${threadDetail.name}, messages: ${threadDetail.messages.length})';
  }
}

/// State indicating an error occurred while loading thread data.
class ThreadError extends ThreadState {
  /// @nodoc
  const ThreadError({required this.message});

  /// The error message.
  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'ThreadError(message: $message)';
}
