import 'package:suhbat/features/chat/data/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Message>> getMessages(String roomId) async {
    final data = await _supabase
        .from('messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => Message.fromMap(e)).toList();
  }

  Future<void> sendMessage(String roomId, String content) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').insert({
      'room_id': roomId,
      'user_id': userId,
      'content': content,
    });
  }
  Stream<List<Message>> messagesStream(String roomId) {
  return _supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at', ascending: true)
      .map((data) => data.map((e) => Message.fromMap(e)).toList());
}
}