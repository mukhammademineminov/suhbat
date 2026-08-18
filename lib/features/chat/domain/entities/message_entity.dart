class MessageEntity {
  final String id;
  final String roomId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? username;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.username,
    this.isRead = false,
  });
}