import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/presentation/widgets/message_list.dart';
import 'package:suhbat/features/chat/providers/chat_controller.dart';
import 'package:suhbat/features/chat/providers/chat_provider.dart';
import 'package:suhbat/features/chat/providers/room_members_provider.dart';
import 'package:go_router/go_router.dart';

import 'package:suhbat/core/providers/active_chat_provider.dart';
import 'package:suhbat/features/widgets/message_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;
  final int memberCount;
  const ChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.memberCount,
  });

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(markMessagesAsReadUseCaseProvider).call(widget.roomId);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.roomName, style: const TextStyle(fontSize: 18)),
            Text(
              '${widget.memberCount} ${widget.memberCount == 0 ? 'member' : 'members'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final router = GoRouter.of(context);
            final didPop = await navigator.maybePop();
            if (!didPop && mounted) router.go('/rooms_chat');
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

                  return messagesAsync.when(
                    data: (messages) => MessageList(
                      items: items,
                      scrollController: _scrollController,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
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
    await ref
        .read(chatControllerProvider.notifier)
        .sendMessage(roomId: widget.roomId, content: content);
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
