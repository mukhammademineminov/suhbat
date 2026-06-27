import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/data/room_member.dart';
import 'package:suhbat/features/chat/data/room_members_repository.dart';
import 'package:suhbat/core/providers/supabase_provider.dart';


final roomMembersRepositoryProvider = Provider((ref) {
  return RoomMembersRepository(ref.watch(supabaseClientProvider));
});

final isRoomMemberProvider = FutureProvider.family<bool, String>((ref, roomId) {
  return ref.watch(roomMembersRepositoryProvider).isMember(roomId);
});

final roomMembersStreamProvider = StreamProvider.family<List<RoomMember>, String>((ref, roomId) {
  return ref.watch(roomMembersRepositoryProvider).watchMembers(roomId);
});
