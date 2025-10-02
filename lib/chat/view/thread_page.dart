import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:companion_connect/chat/bloc/thread_bloc.dart';
import 'package:companion_connect/chat/bloc/thread_event.dart';
import 'package:companion_connect/chat/bloc/thread_state.dart';
import 'package:companion_connect/chat/models/thread_detail.dart';
import 'package:companion_connect/chat/models/message.dart';

/// Thread page for displaying individual thread conversations
class ThreadPage extends StatelessWidget {
  /// Creates a [ThreadPage] instance.
  const ThreadPage({
    required this.threadId,
    super.key,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppBloc, AppState, AppState>(
      selector: (state) => state,
      builder: (context, appState) {
        return _ThreadPageContent(
          threadId: threadId,
        );
      },
    );
  }
}

class _ThreadPageContent extends StatefulWidget {
  const _ThreadPageContent({
    required this.threadId,
  });

  final String threadId;

  @override
  State<_ThreadPageContent> createState() => _ThreadPageContentState();
}

class _ThreadPageContentState extends State<_ThreadPageContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ThreadBloc(
            apiClient: context.read<ApiClient>(),
            appBloc: context.read<AppBloc>(),
          )..add(
            LoadThreadDetail(
              threadId: widget.threadId,
            ),
          ),
      child: _ThreadScaffold(
        threadId: widget.threadId,
      ),
    );
  }
}

class _ThreadScaffold extends StatelessWidget {
  const _ThreadScaffold({
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _ThreadAppBar(
        threadId: threadId,
      ),
      body: BlocBuilder<ThreadBloc, ThreadState>(
        builder: (context, state) {
          if (state is ThreadInitial || state is ThreadLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ThreadLoaded) {
            return _ThreadContent(threadDetail: state.threadDetail);
          } else if (state is ThreadSendingMessage) {
            return _ThreadContent(threadDetail: state.threadDetail);
          } else if (state is ThreadError) {
            return _ErrorView(
              message: state.message,
              threadId: threadId,
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class _ThreadContent extends StatefulWidget {
  const _ThreadContent({required this.threadDetail});

  final ThreadDetail threadDetail;

  @override
  State<_ThreadContent> createState() => _ThreadContentState();
}

class _ThreadContentState extends State<_ThreadContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom when widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(_ThreadContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to bottom when thread is refreshed with new messages
    if (widget.threadDetail.messages.length !=
        oldWidget.threadDetail.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottomImmediately();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomImmediately() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Thread info header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.threadDetail.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (widget.threadDetail.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.threadDetail.description!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.threadDetail.model,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[500],
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.threadDetail.messages.length} messages',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[500],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: BlocListener<ThreadBloc, ThreadState>(
              listener: (context, state) {
                // Auto-scroll to bottom when thread is loaded or refreshed
                if (state is ThreadLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottomImmediately();
                  });
                }
              },
              child: widget.threadDetail.messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages yet.\nStart a conversation!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.threadDetail.messages.length,
                      itemBuilder: (context, index) {
                        final message = widget.threadDetail.messages[index];
                        return _MessageBubble(message: message);
                      },
                    ),
            ),
          ),

          // Message input
          BlocBuilder<ThreadBloc, ThreadState>(
            builder: (context, state) {
              return _MessageInput(
                messageController: _messageController,
                onSendMessage: _sendMessage,
                isSending: state is ThreadSendingMessage,
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      // Clear the input immediately
      _messageController.clear();

      // Send the message
      context.read<ThreadBloc>().add(SendMessage(content: content));

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isAssistant = message.role == 'assistant';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[500] : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.role,
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isAssistant) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.smart_toy,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          message.model,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.blue[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.messageController,
    required this.onSendMessage,
    this.isSending = false,
  });

  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: isSending ? null : onSendMessage,
            child: isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.threadId,
  });

  final String message;
  final String threadId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ThreadBloc>().add(
                LoadThreadDetail(
                  threadId: threadId,
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ThreadAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ThreadAppBar({
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BlocBuilder<ThreadBloc, ThreadState>(
        builder: (context, state) {
          if (state is ThreadLoaded) {
            return Text(state.threadDetail.name);
          }
          return const Text('Thread');
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<ThreadBloc>().add(
              LoadThreadDetail(
                threadId: threadId,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
