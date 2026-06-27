import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/features/chat/data/room_member.dart';

class RoomMembersRepository {
  final SupabaseClient _client;
  RoomMembersRepository(this._client);

  Future<void> joinRoom(String roomId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('room_members').insert({
      'room_id': roomId,
      'user_id': userId,
    });
  }

  Future<void> leaveRoom(String roomId) async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from('room_members')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

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

  Stream<List<RoomMember>> watchMembers(String roomId) {
    return _client
        .from('room_members')
        .stream(primaryKey: ['room_id', 'user_id'])
        .eq('room_id', roomId)
        .map((rows) => rows.map(RoomMember.fromJson).toList());
  }
}