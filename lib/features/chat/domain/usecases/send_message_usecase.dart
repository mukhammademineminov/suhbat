import 'package:suhbat/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String content,
  }) {
    return repository.sendMessage(roomId, content);
  }
}