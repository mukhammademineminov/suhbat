import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:suhbat/features/chat/providers/rooms_provider.dart';

import 'package:suhbat/features/profile/providers/profile_provider.dart';
import 'package:suhbat/utils/dialog_utils.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final profileAsync = ref.watch(profilesprovider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        leading: GestureDetector(
          onTap: () => context.push('/profile'),
          child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            child: profileAsync.when(
              data: (profile) => Text(profile.avatarChar),
              loading: () => const SizedBox(),
              error: (_, _) => const Text('?'),
            )
          )
        ),),
        
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final confirm = await DialogUtils.showConfirmDialog(
                context,
                title: 'Logout',
                content: 'Are you sure to logout?',
              );

              if (confirm) {
                await Supabase.instance.client.auth.signOut();
              }
            },
          ),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoomDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (rooms) => ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return ListTile(
              title: Text(room.name),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/chat/${room.id}/${room.name}');
              },
            );
          },
        ),
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
