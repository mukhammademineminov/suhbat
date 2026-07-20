class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final String? otherUsername;
  final String? otherUserId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.otherUsername,
    this.otherUserId,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Conversation.fromMap(
    Map<String, dynamic> map,
    String currentUserId,
    Map<String, dynamic> otherProfile, {
    String? lastMessage,
    DateTime? lastMessageTime,
    int unreadCount = 0,
  }) {
    return Conversation(
      id: map['id'] as String,
      user1Id: map['user1_id'] as String,
      user2Id: map['user2_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      otherUsername: otherProfile['username'] as String?,
      otherUserId: otherProfile['id'] as String?,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
    );
  }
}
