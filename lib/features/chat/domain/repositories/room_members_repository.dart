import 'package:suhbat/features/chat/domain/entities/room_member_entity.dart';
abstract class RoomMembersRepository {
  Future<void> joinRoom(String roomId);
  Future<void> leaveRoom(String roomId);
  Future<bool> isMember(String roomId);
  Stream<List<RoomMemberEntity>> watchMembers(String roomId);
}