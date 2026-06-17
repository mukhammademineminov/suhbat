import 'package:suhbat/features/direct_message/data/dm_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/features/direct_message/data/conversation.dart';

class DmRepository {
  final _supabase = Supabase.instance.client;

  Future<List<DmMessage>> getMessages(String conversationId) async {
    final data = await _supabase
        .from('direct_messages')
        .select('*, profiles(username)')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => DmMessage.fromMap(e)).toList();
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('direct_messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
    });
  }

  Future<String> getOrCreateConversation(String otherUserId) async {
    final userId = _supabase.auth.currentUser!.id;
    if (userId == otherUserId) throw Exception('Cannot start a conversation with yourself');

    final existing = await _supabase
        .from('conversations')
        .select()
        .or(
          'and(user1_id.eq.$userId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$userId)',
        )
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final result = await _supabase
        .from('conversations')
        .insert({'user1_id': userId, 'user2_id': otherUserId})
        .select()
        .single();

    return result['id'] as String;
  }

  Stream<List<DmMessage>> messagesStream(String conversationId) {
    return _supabase
        .from('direct_messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .asyncMap((data) async {
          final userIds = data
              .map((e) => e['sender_id'] as String)
              .toSet()
              .toList();
          final profiles = await _supabase
              .from('profiles')
              .select('id, username')
              .inFilter('id', userIds);
          final profileMap = {
            for (final p in profiles)
              p['id'] as String: p['username'] as String?,
          };
          return data
              .map(
                (e) => DmMessage.fromMap({
                  ...e,
                  'profiles': {'username': profileMap[e['sender_id']]},
                }),
              )
              .toList();
        });
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase
          .from('direct_messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Conversation>> getConversations() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('conversations')
        .select()
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('created_at', ascending: false);

    final List<Conversation> conversations = [];

    for (final e in data) {
      final otherUserId = e['user1_id'] == userId
          ? e['user2_id']
          : e['user1_id'];

      final profile = await _supabase
          .from('profiles')
          .select('id, username')
          .eq('id', otherUserId)
          .single();

      conversations.add(Conversation.fromMap(e, userId, profile));
    }
    return conversations;
  }

  Stream<List<Conversation>> conversationsStream() {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final filteredData = data
              .where((e) => e['user1_id'] == userId || e['user2_id'] == userId)
              .toList();

          final otherUserIds = filteredData
              .map((e) => e['user1_id'] == userId
                  ? e['user2_id'] as String
                  : e['user1_id'] as String)
              .toSet()
              .toList();

          final profiles = otherUserIds.isEmpty
              ? <Map<String, dynamic>>[]
              : await _supabase
                  .from('profiles')
                  .select('id, username')
                  .inFilter('id', otherUserIds);

          final profileMap = {
            for (final p in profiles) p['id'] as String: p['username'] as String?,
          };

          return filteredData.map((e) {
            final otherUserId = e['user1_id'] == userId
                ? e['user2_id'] as String
                : e['user1_id'] as String;

            return Conversation.fromMap(
              e,
              userId,
              {'username': profileMap[otherUserId]},
            );
          }).toList();
        });
  }
}
