import 'package:suhbat/features/chat/domain/repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;
  MarkMessagesAsReadUseCase(this.repository);

  Future<void> call(String roomId) {
    return repository.markMessagesAsRead(roomId);
  }
}