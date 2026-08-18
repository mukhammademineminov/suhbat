import 'package:suhbat/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<MessageEntity>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
  Stream<List<MessageEntity>> messagesStream(String roomId);
  Future<void> markMessagesAsRead(String roomId);
}