import 'package:flutter/material.dart';
import 'package:suhbat/features/widgets/app_avatar.dart';
import 'package:suhbat/utils/format_message_time.dart';

class ChatListTile extends StatelessWidget {
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final VoidCallback onTap;
  final int unreadCount;

  const ChatListTile({
    super.key,
    required this.title,
    this.lastMessage,
    this.lastMessageTime,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AppAvatar(label: title, radius: 24, fontSize: 18),
      title: Text(title),
      subtitle: lastMessage != null
          ? Text(lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : Text(
              'No messages yet',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessageTime != null)
            Text(
              '${lastMessageTime!.toLocal().hour}:${lastMessageTime!.toLocal().minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
