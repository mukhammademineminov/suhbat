import 'package:suhbat/features/chat/domain/entities/message_entity.dart';
import 'package:suhbat/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;
  WatchMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String roomId) {
    return repository.messagesStream(roomId);
  }
}