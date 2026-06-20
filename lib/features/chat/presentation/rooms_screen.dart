import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:suhbat/features/chat/providers/rooms_provider.dart';
import 'package:suhbat/features/direct_message/providers/dm_provider.dart';
import 'package:suhbat/features/profile/providers/profile_provider.dart';
import 'package:suhbat/features/search/presentation/search_delegate.dart';
import 'package:suhbat/features/direct_message/data/dm_repository.dart';

import 'package:suhbat/features/widgets/app_avatar.dart';

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
                return ListTile(
                  title: Text(room.name),
                  leading: AppAvatar(
                    label: room.name,
                    radius: 20,
                    fontSize: 16,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/chat/${room.id}/${room.name}');
                  },
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

                  return ListTile(
                    title: Text(conversation.otherUsername ?? 'Unknown'),
                    leading: AppAvatar(
                      label: conversation.otherUsername ?? 'U',
                      radius: 20,
                      fontSize: 16,
                    ),
                    onTap: () {
                      context.push(
                        '/dm/${conversation.id}/${conversation.otherUsername}',
                      );
                    },
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
            await Supabase.instance.client.from('rooms').insert({'name': name});
            ref.invalidate(roomsProvider);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
