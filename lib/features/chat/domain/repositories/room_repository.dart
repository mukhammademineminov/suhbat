import 'package:suhbat/features/chat/data/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getMyRooms();
  Future<Room> createRoom(String name);
  Future<int> getUnreadCount(String roomId);
}