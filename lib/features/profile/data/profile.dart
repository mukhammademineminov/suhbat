class Profile {
  final String id;
  final String username;
  final String avatarUrl;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.createdAt,
  });

  String get avatarChar => username.isNotEmpty ? username[0].toUpperCase() : '?';

factory Profile.fromMap(Map<String, dynamic> map) {
  return Profile(
    id: map['id'] as String? ?? '',
    username: map['username'] as String? ?? 'User',
    avatarUrl: map['avatar_url'] as String? ?? '',
    createdAt: map['created_at'] != null 
      ? DateTime.parse(map['created_at'] as String)
      : DateTime.now(),
  );
}
}
