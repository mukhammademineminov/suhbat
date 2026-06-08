import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:suhbat/features/chat/providers/chat_provider.dart';
import 'package:suhbat/features/chat/presentation/widgets/message_bubble.dart';
import 'package:suhbat/features/chat/data/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;
  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(chatRepositoryProvider).markMessagesAsRead(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.roomId));

    ref.listen(messagesProvider(widget.roomId), (_, next) {
      next.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  final List<Object> items = [];
                  DateTime? lastDate;

                  for (final message in messages) {
                    final messageDate = DateTime(
                      message.createdAt.toLocal().year,
                      message.createdAt.toLocal().month,
                      message.createdAt.toLocal().day,
                    );

                    if (lastDate == null || lastDate != messageDate) {
                      items.add(messageDate); 
                      lastDate = messageDate;
                    }
                    items.add(message);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      if (item is DateTime) {
                        final now = DateTime.now().toLocal();
                        final today = DateTime(now.year, now.month, now.day);
                        final yesterday = today.subtract(
                          const Duration(days: 1),
                        );

                        String label;
                        if (item == today) {
                          label = 'Today';
                        } else if (item == yesterday) {
                          label = 'Yesterday';
                        } else {
                          label =
                              '${item.day.toString().padLeft(2, '0')}.${item.month.toString().padLeft(2, '0')}.${item.year}';
                        }
                        return Center(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      final message = item as Message;
                      final isMe =
                          message.userId ==
                          Supabase.instance.client.auth.currentUser!.id;
                      final isSameAsPrevious =
                          index < items.length - 1 &&
                          items[index + 1] is Message &&
                          (items[index + 1] as Message).userId ==
                              message.userId;

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        isSameAsPrevious: isSameAsPrevious,
                      );
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 10,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    await ref.read(chatRepositoryProvider).sendMessage(widget.roomId, content);

    //scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      }
    });
  }
}
