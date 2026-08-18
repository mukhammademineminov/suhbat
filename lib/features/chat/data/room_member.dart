import 'package:suhbat/features/chat/domain/entities/room_member_entity.dart';

class RoomMember extends RoomMemberEntity {
  RoomMember({
    required super.roomId,
    required super.userId,
    required super.role,
    required super.joinedAt,
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
