import 'package:flutter/material.dart';

class Room {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final int memberCount;

  Room({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.memberCount = 0,
  });

  factory Room.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final messages = (map['messages'] as List?) ?? [];

    // last message
    Map<String, dynamic>? lastMsg;
    if (messages.isNotEmpty) {
      final sorted = List<Map<String, dynamic>>.from(messages)
        ..sort(
          (a, b) => DateTime.parse(
            b['created_at'],
          ).compareTo(DateTime.parse(a['created_at'])),
        );
      lastMsg = sorted.first;
    }

    //
    final members = map['room_members'] as List?;
    final memberCount = members?.length ?? 0;

    //unread count
    final unreadCount = currentUserId != null
        ? messages
              .where(
                (m) => m['is_read'] == false && m['user_id'] != currentUserId,
              )
              .length
        : 0;

    return Room(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastMessage: lastMsg?['content'] as String?,
      lastMessageTime: lastMsg != null
          ? DateTime.parse(lastMsg['created_at'])
          : null,
      unreadCount: unreadCount,
      memberCount: memberCount
    );
  }
}
