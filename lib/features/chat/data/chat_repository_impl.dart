import 'package:suhbat/features/chat/data/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;
  ChatRepositoryImpl(this._supabase);

@override
  Future<List<Message>> getMessages(String roomId) async {
    final data = await _supabase
        .from('messages')
        .select('*, profiles(username)')
        .eq('room_id', roomId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => Message.fromMap(e)).toList();
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'room_id': roomId,
      'user_id': userId,
      'content': content,
    });
  }

  @override
  Stream<List<Message>> messagesStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .asyncMap((data) async {
          final userIds = data.map((e) => e['user_id'] as String).toSet().toList();

          final profiles = await _supabase
              .from('profiles')
              .select('id, username')
              .inFilter('id', userIds);

          final profileMap = {
            for (final p in profiles) p['id'] as String: p['username'] as String?,
          };

          return data
              .map(
                (e) => Message.fromMap({
                  ...e,
                  'profiles': {'username': profileMap[e['user_id']]},
                }),
              )
              .toList();
        });
  }

  @override
  Future<void> markMessagesAsRead(String roomId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('user_id', userId)
        .eq('is_read', false);
  }
}