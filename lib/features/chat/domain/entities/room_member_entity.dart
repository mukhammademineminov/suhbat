class RoomMemberEntity {
  final String roomId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  const RoomMemberEntity({
    required this.roomId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });
}