import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/data/chat_repository.dart';
import 'package:suhbat/features/chat/data/message.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, roomId) {
  return ref.read(chatRepositoryProvider).messagesStream(roomId);
});