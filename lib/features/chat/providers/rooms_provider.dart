import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/data/room.dart';
import 'package:suhbat/features/chat/data/room_repository.dart';
import 'package:suhbat/core/providers/supabase_provider.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository(ref.watch(supabaseClientProvider));
});

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return ref.watch(roomRepositoryProvider).getMyRooms();
});