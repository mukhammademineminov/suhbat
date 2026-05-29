class Message {
  final String id;
  final String roomId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? username;
  final bool isRead;


  Message({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.username,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      username: map['profiles']?['username'] as String?,
      isRead: map['is_read'] as bool,
    );
  }
}