import 'package:suhbat/features/chat/domain/repositories/room_members_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/features/chat/data/room_member.dart';

class RoomMembersRepositoryImpl implements RoomMembersRepository {
  final SupabaseClient _client;
  RoomMembersRepositoryImpl(this._client);

  @override
  Future<void> joinRoom(String roomId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('room_members').insert({
      'room_id': roomId,
      'user_id': userId,
    });
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('room_members')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

  @override
  Future<bool> isMember(String roomId) async {
    final userId = _client.auth.currentUser!.id;
    final res = await _client
        .from('room_members')
        .select()
        .eq('room_id', roomId)
        .eq('user_id', userId)
        .maybeSingle();
    return res != null;
  }

  @override
  Stream<List<RoomMember>> watchMembers(String roomId) {
    return _client
        .from('room_members')
        .stream(primaryKey: ['room_id', 'user_id'])
        .eq('room_id', roomId)
        .map((rows) => rows.map(RoomMember.fromJson).toList());
  }
}