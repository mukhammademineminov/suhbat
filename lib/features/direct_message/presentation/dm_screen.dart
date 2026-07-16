import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:suhbat/services/notification_service.dart';

import 'package:suhbat/features/widgets/message_bubble.dart';
import 'package:suhbat/features/widgets/date_separator.dart';

import 'package:suhbat/features/direct_message/providers/dm_provider.dart';
import 'package:suhbat/core/providers/active_chat_provider.dart';
import 'package:suhbat/features/direct_message/data/dm_message.dart';
import 'package:suhbat/features/widgets/message_input.dart';

class DMChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String userName;
  const DMChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  ConsumerState<DMChatScreen> createState() => _DMChatScreenState();
}

class _DMChatScreenState extends ConsumerState<DMChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(dmRepositoryProvider)
          .markMessagesAsRead(widget.conversationId);
      // Set the active chat conversation ID in the provider
      ref.read(activeChatProvider.notifier).state = widget.conversationId;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Set active chat to null synchronously to avoid using `ref` after dispose
    try {
      ref.read(activeChatProvider.notifier).state = null;
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(dmMessagesProvider(widget.conversationId));

    ref.listen(dmMessagesProvider(widget.conversationId), (previous, next) {
      next.whenData((messages) {
        //mark as read
        ref
            .read(dmRepositoryProvider)
            .markMessagesAsRead(widget.conversationId);
        // notification
        if (previous != null) {
          final prevMessages = previous.value ?? [];
          if (messages.length > prevMessages.length) {
            final newMessage = messages.last;
            if (newMessage.senderId !=
                Supabase.instance.client.auth.currentUser!.id) {
              NotificationService.showNotification(
                title: newMessage.username ?? 'New message',
                body: newMessage.content,
              );
            }
          }
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
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final router = GoRouter.of(context);
            final didPop = await navigator.maybePop();
            if (!didPop && mounted) {
              router.go('/rooms_chat');
            }
          },
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
                        return DateSeparator(date: item);
                      }

                      final message = item as DmMessage;
                      final isMe =
                          message.senderId ==
                          Supabase.instance.client.auth.currentUser!.id;
                      final isSameAsPrevious =
                          index < items.length - 1 &&
                          items[index + 1] is DmMessage &&
                          (items[index + 1] as DmMessage).senderId ==
                              message.senderId;

                      return MessageBubble(
                        content: message.content,
                        createdAt: message.createdAt,
                        username: message.username,
                        isRead: message.isRead,
                        isMe: isMe,
                        isSameAsPrevious: isSameAsPrevious,
                        showUsername: false,
                        userId: message.senderId,
                      );
                    },
                  );
                },
              ),
            ),
            MessageInput(controller: _messageController, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    await ref
        .read(dmRepositoryProvider)
        .sendMessage(widget.conversationId, content);

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
