import 'package:suhbat/features/chat/data/message.dart';

abstract class ChatRepository {
  Future<List<Message>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
  Stream<List<Message>> messagesStream(String roomId);
  Future<void> markMessagesAsRead(String roomId);
}
