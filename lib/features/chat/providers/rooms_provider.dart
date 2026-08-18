import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/domain/entities/room_entity.dart';
import 'package:suhbat/features/chat/data/room_repository_impl.dart';
import 'package:suhbat/features/chat/domain/repositories/room_repository.dart';
import 'package:suhbat/core/providers/supabase_provider.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(ref.watch(supabaseClientProvider));
});

final roomsProvider = FutureProvider<List<RoomEntity>>((ref) async {
  return ref.watch(roomRepositoryProvider).getMyRooms();
});