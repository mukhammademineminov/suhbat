import 'package:flutter/material.dart';
import 'package:suhbat/features/chat/data/room.dart';
import 'package:suhbat/features/profile/data/profile.dart';
import 'package:suhbat/features/search/data/search_repository.dart';

import 'package:suhbat/features/widgets/app_avatar.dart';

class RoomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return const SizedBox();

    return FutureBuilder(
      future: SearchRepository().search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final rooms = snapshot.data!['rooms'] as List<Room>;
        final users = snapshot.data!['users'] as List<Profile>;

        return ListView.builder(
          itemCount: rooms.length + users.length,
          itemBuilder: (context, index) {
            if (index < rooms.length) {
              return ListTile(
                title: Text(rooms[index].name),
                leading: AppAvatar(
                  label: rooms[index].name,
                  radius: 20,
                  fontSize: 16,
                ),
                onTap: () {
                  close(
                    context,
                    'room:${rooms[index].id}:${rooms[index].name}',
                  );
                },
              );
            }
            final user = users[index - rooms.length];
            return ListTile(
              title: Text(user.username),
              leading: AppAvatar(
                label: user.username,
                radius: 20,
                fontSize: 16,
              ),
              onTap: () {
                close(context, 'user:${user.id}:${user.username}');
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
