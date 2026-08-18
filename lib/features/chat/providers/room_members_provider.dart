import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/data/room_members_repository_impl.dart';
import 'package:suhbat/features/chat/domain/entities/room_member_entity.dart';
import 'package:suhbat/features/chat/domain/repositories/room_members_repository.dart';
import 'package:suhbat/core/providers/supabase_provider.dart';

final roomMembersRepositoryProvider = Provider<RoomMembersRepository>((ref) {
  return RoomMembersRepositoryImpl(ref.watch(supabaseClientProvider));
});

final isRoomMemberProvider = FutureProvider.family<bool, String>((ref, roomId) {
  return ref.watch(roomMembersRepositoryProvider).isMember(roomId);
});

final roomMembersStreamProvider = StreamProvider.family<List<RoomMemberEntity>, String>((ref, roomId) {
  return ref.watch(roomMembersRepositoryProvider).watchMembers(roomId);
});