import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/providers/room_members_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:suhbat/features/chat/providers/chat_provider.dart';
import 'package:suhbat/core/providers/active_chat_provider.dart';
import 'package:suhbat/features/widgets/message_bubble.dart';
import 'package:suhbat/features/chat/data/message.dart';
import 'package:suhbat/features/widgets/date_separator.dart';
import 'package:suhbat/features/widgets/message_input.dart';
import 'package:suhbat/features/direct_message/data/dm_repository.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    Future.microtask(() {
    ref.read(activeChatProvider.notifier).state = null;
  });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint('ChatScreen initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('PostFrameCallback running');
      try {
        await ref
            .read(chatRepositoryProvider)
            .markMessagesAsRead(widget.roomId);
        debugPrint('markMessagesAsRead success');
        // Set the active chat room ID in the provider
        ref.read(activeChatProvider.notifier).state = widget.roomId;
      } catch (e) {
        debugPrint('Error marking messages as read: $e.toString()');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.roomId));
    final isMemberAsync = ref.watch(isRoomMemberProvider(widget.roomId));
    final isMember = isMemberAsync.value ?? false;

    ref.listen(messagesProvider(widget.roomId), (_, next) {
      next.whenData((_) {
        ref.read(chatRepositoryProvider).markMessagesAsRead(widget.roomId);
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
                    return isMember
                        ? const Center(child: Text('No messages yet'))
                        : const Center(
                            child: Text('Join the room to view messages'),
                          );
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

                      final message = item as Message;
                      final isMe =
                          message.userId ==
                          Supabase.instance.client.auth.currentUser!.id;
                      final isSameAsPrevious =
                          index < items.length - 1 &&
                          items[index + 1] is Message &&
                          (items[index + 1] as Message).userId ==
                              message.userId;
                      final username = message.username;

                      return MessageBubble(
                        key: ValueKey(message.id),
                        content: message.content,
                        createdAt: message.createdAt,
                        username: username,
                        isRead: message.isRead,
                        isMe: isMe,
                        isSameAsPrevious: isSameAsPrevious,
                        userId: message.userId,
                        onAvatarTap: () async {
                          if (isMe) return;
                          final conversationId = await DmRepository()
                              .getOrCreateConversation(message.userId);
                          if (!context.mounted) return;
                          context.push(
                            '/dm/$conversationId/${message.username}',
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            isMemberAsync.when(
              data: (isMember) => isMember
                  ? MessageInput(
                      controller: _messageController,
                      onSend: _sendMessage,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),

                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                await ref
                                    .read(roomMembersRepositoryProvider)
                                    .joinRoom(widget.roomId);
                                ref.invalidate(
                                  isRoomMemberProvider(widget.roomId),
                                );
                              },
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(),
                              )
                            : Text('Join Room'),
                      ),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
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
