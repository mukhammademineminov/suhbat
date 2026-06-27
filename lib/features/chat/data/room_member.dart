class RoomMember {
  final String roomId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  RoomMember({
    required this.roomId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      roomId: json['room_id'],
      userId: json['user_id'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}