import 'package:flutter/material.dart';
import 'package:suhbat/features/widgets/app_avatar.dart';

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
          ? Text(lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600),)
          : Text(''),
      trailing: lastMessageTime != null
          ? Text(
              '${lastMessageTime!.hour}:${lastMessageTime!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            )
          : null,
      onTap: onTap,
    );
  }
}