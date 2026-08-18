import 'package:suhbat/features/chat/data/room_member.dart';

abstract class RoomMembersRepository {
  Future<void> joinRoom(String roomId);
  Future<void> leaveRoom(String roomId);
  Future<bool> isMember(String roomId);
  Stream<List<RoomMember>> watchMembers(String roomId);
}