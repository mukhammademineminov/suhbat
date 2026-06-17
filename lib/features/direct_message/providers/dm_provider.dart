import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/direct_message/data/conversation.dart';

import 'package:suhbat/features/direct_message/data/dm_repository.dart';
import 'package:suhbat/features/direct_message/data/dm_message.dart';


final dmRepositoryProvider = Provider((ref) => DmRepository());

final messagesProvider = StreamProvider.family<List<DmMessage>, String>((ref, roomId) {
  return ref.read(dmRepositoryProvider).messagesStream(roomId);
});

final conversationProvider = StreamProvider.autoDispose<List<Conversation>>((ref) {
  return ref.watch(dmRepositoryProvider).conversationsStream();
});

final dmMessagesProvider = StreamProvider.family<List<DmMessage>, String>((ref, conversationId) {
  return ref.read(dmRepositoryProvider).messagesStream(conversationId);
});