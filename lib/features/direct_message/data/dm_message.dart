class DmMessage {
  final String id;
  final DateTime createdAt;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final String? username;

  DmMessage({
    required this.id,
    required this.createdAt,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    this.username,
  });

  factory DmMessage.fromMap(Map<String, dynamic> map) {
    return DmMessage(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      isRead: map['is_read'] as bool? ?? false,
      username: map['profiles']?['username'] as String?,
    );
  }
}
