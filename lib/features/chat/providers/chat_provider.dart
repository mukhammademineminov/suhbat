import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/data/chat_repository.dart';
import 'package:suhbat/features/chat/data/message.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

final messagesProvider = FutureProvider.family<List<Message>, String>((ref, roomId) async {
  return ref.read(chatRepositoryProvider).getMessages(roomId);
});