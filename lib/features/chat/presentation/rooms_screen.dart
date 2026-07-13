import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/providers/room_members_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/services/notification_service.dart';
import 'package:suhbat/core/providers/global_messages_provider.dart';
import 'package:suhbat/core/providers/active_chat_provider.dart';
import 'package:suhbat/features/chat/providers/rooms_provider.dart';
import 'package:suhbat/features/direct_message/providers/dm_provider.dart';
import 'package:suhbat/features/profile/providers/profile_provider.dart';
import 'package:suhbat/features/search/presentation/search_delegate.dart';
import 'package:suhbat/features/direct_message/data/dm_repository.dart';

import 'package:suhbat/features/widgets/app_avatar.dart';
import 'package:suhbat/features/widgets/chat_list_tile.dart';
import 'package:suhbat/utils/dialog_utils.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        ref.invalidate(conversationProvider);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final profileAsync = ref.watch(profilesprovider);
    final directMessagesAsync = ref.watch(conversationProvider);

    ref.listen(globalMessagesProvider, (previous, next) {
      debugPrint('Global messages updated: $next');
    next.whenData((message) {
      debugPrint('Latest message: $message');

      if (message == null) return;
      final activeChat = ref.read(activeChatProvider);
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      
      if (message['user_id'] != currentUserId && 
          activeChat != message['room_id']) {
            debugPrint('Notification triggered for message: $message');
        NotificationService.showNotification(
          title: 'New message',
          body: message['content'] ?? '',
        );
        ref.invalidate(roomsProvider);
      }
    });
  });

  ref.listen(globalDmMessagesProvider, (previous, next) {
    debugPrint('Global DM messages updated: $next');
    next.whenData((message) {
      debugPrint('Latest DM message: $message');
      if (message == null) return;
      final activeChat = ref.read(activeChatProvider);
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      
      if (message['sender_id'] != currentUserId && 
          activeChat != message['conversation_id']) {
            debugPrint('Notification triggered for message: $message');
        NotificationService.showNotification(
          title: 'New message',
          body: message['content'] ?? '',
        );
        ref.invalidate(conversationProvider);
      }
    });
  });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suhbat'),
        leading: GestureDetector(
          onTap: () => context.push('/profile'),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AppAvatar(
              label: profileAsync.when(
                data: (profile) => profile.username,
                loading: () => '',
                error: (_, _) => '?',
              ),
              radius: 20,
              fontSize: 16,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Rooms'),
            Tab(text: 'Direct Messages'),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: RoomSearchDelegate(),
              );
              if (result == null || !context.mounted) return;

              if (result.startsWith('room:')) {
                final parts = result.split(':');
                ref.invalidate(roomsProvider);
                context.push('/chat/${parts[1]}/${parts[2]}');
              } else if (result.startsWith('user:')) {
                final parts = result.split(':');
                final conversationId = await DmRepository()
                    .getOrCreateConversation(parts[1]);

                if (!context.mounted) return;
                ref.invalidate(conversationProvider);
                context.push('/dm/$conversationId/${parts[2]}');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          roomsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (rooms) => ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Dismissible(
                  key: Key(room.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    final confirm = await DialogUtils.showConfirmDialog(
                      context,
                      title: 'Leave Room',
                      content: 'Are you sure you want to leave "${room.name}"?',
                    );

                    if (confirm && context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      await ref
                          .read(roomMembersRepositoryProvider)
                          .leaveRoom(room.id);
                      ref.invalidate(roomsProvider);

                      if (context.mounted) Navigator.pop(context);
                    }

                    return false;
                  },
                  onDismissed: null, 
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.exit_to_app, color: Colors.white),
                  ),
                  child: ChatListTile(
                    title: room.name,
                    lastMessage: room.lastMessage,
                    lastMessageTime: room.lastMessageTime,
                    onTap: () => context.push('/chat/${room.id}/${room.name}'),
                  ),
                );
              },
            ),
          ),
          directMessagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (conversations) {
              if (conversations.isEmpty) {
                return const Center(child: Text('No conversations yet'));
              }
              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return Dismissible(
                    key: Key(conversation.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      final confirm = await DialogUtils.showConfirmDialog(
                        context,
                        title: 'Delete Conversation',
                        content: 'This will delete all messages. Continue?',
                      );

                      if (confirm && context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await ref
                            .read(dmRepositoryProvider)
                            .deleteConversation(conversation.id);
                        ref.invalidate(conversationProvider);

                        if (context.mounted) Navigator.pop(context);
                      }

                      return false;
                    },
                    onDismissed: (_) async {
                      await ref
                          .read(dmRepositoryProvider)
                          .deleteConversation(conversation.id);
                      if (!context.mounted) {
                        ref.invalidate(conversationProvider);
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ChatListTile(
                      title: conversation.otherUsername ?? 'Unknown',
                      lastMessage: conversation.lastMessage,
                      lastMessageTime: conversation.lastMessageTime,
                      onTap: () => context.push(
                        '/dm/${conversation.id}/${conversation.otherUsername}',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showCreateRoomDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New Room'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Room name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;

            await ref.read(roomRepositoryProvider).createRoom(name);
            ref.invalidate(roomsProvider);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
