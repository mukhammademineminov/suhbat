import 'package:suhbat/features/chat/domain/entities/message_entity.dart';

class Message extends MessageEntity {
  const Message({
    required super.id,
    required super.roomId,
    required super.userId,
    required super.content,
    required super.createdAt,
    super.username,
    super.isRead,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      username: map['profiles']?['username'] as String?,
      isRead: (map['is_read'] as bool?) ?? false,
    );
  }
}