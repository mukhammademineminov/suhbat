import 'package:suhbat/features/chat/domain/entities/room_entity.dart';

abstract class RoomRepository {
  Future<List<RoomEntity>> getMyRooms();
  Future<RoomEntity> createRoom(String name);
  Future<int> getUnreadCount(String roomId);
}