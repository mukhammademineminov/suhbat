import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/data/room.dart';
import 'package:suhbat/features/chat/data/rooms_repository.dart';

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return RoomsRepository().getRooms();
});