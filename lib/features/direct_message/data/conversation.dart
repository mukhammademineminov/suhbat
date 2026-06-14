class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final String? otherUsername;
  final String? otherUserId;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.otherUsername,
    this.otherUserId,
  });

  factory Conversation.fromMap(
    Map<String, dynamic> map,
    String currentUserId,
    Map<String, dynamic> otherProfile,
  ) {
    final otherUserId = map['user1_id'] == currentUserId
        ? map['user2_id'] as String
        : map['user1_id'] as String;

    return Conversation(
      id: map['id'] as String,
      user1Id: map['user1_id'] as String,
      user2Id: map['user2_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      otherUsername: otherProfile['username'] as String?,
      otherUserId: otherUserId,
    );
  }
}
