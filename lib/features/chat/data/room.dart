class Room {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Room({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
  final messages = (map['messages'] as List?) ?? [];
  
  Map<String, dynamic>? lastMsg;
  if (messages.isNotEmpty) {
    final sorted = List<Map<String, dynamic>>.from(messages)
      ..sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
    lastMsg = sorted.first;
  }

  return Room(
    id: map['id'] as String,
    name: map['name'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    lastMessage: lastMsg?['content'] as String?,
    lastMessageTime: lastMsg != null ? DateTime.parse(lastMsg['created_at']) : null,
  );
}
}