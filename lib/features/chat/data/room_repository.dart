import 'package:suhbat/features/chat/data/room.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomRepository {
  final SupabaseClient _client;
  RoomRepository(this._client);

  Future<List<Room>> getMyRooms() async {
    final userId = _client.auth.currentUser!.id;

    final memberData = await _client
        .from('room_members')
        .select('room_id')
        .eq('user_id', userId)
        .order('joined_at', ascending: true);

    if (memberData.isEmpty) return [];

    final roomIds = (memberData as List)
        .map((e) => e['room_id'] as String)
        .toList();

    final roomData = await _client
        .from('rooms')
        .select('*, messages(content, created_at, is_read, user_id)')
        .inFilter('id', roomIds);

    return (roomData as List)
        .map((e) => Room.fromMap(e, currentUserId: userId))
        .toList();
  }

  Future<Room> createRoom(String name) async {
    final userId = _client.auth.currentUser!.id;

    final roomJson = await _client
        .from('rooms')
        .insert({'name': name, 'created_by': userId})
        .select()
        .single();

    await _client.from('room_members').insert({
      'room_id': roomJson['id'],
      'user_id': userId,
      'role': 'owner',
    });

    return Room.fromMap(roomJson);
  }

  Future<int> getUnreadCount(String roomId) async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('messages')
        .select()
        .eq('room_id', roomId)
        .eq('is_read', false)
        .neq('user_id', userId);

    return (data as List).length;
  }
}
