import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/core/providers/supabase_provider.dart';
import 'package:suhbat/features/chat/data/chat_repository_impl.dart';
import 'package:suhbat/features/chat/domain/entities/message_entity.dart';
import 'package:suhbat/features/chat/domain/repositories/chat_repository.dart';
import 'package:suhbat/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:suhbat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:suhbat/features/chat/domain/usecases/mark_messages_as_read_usecase.dart';


final messagesProvider = StreamProvider.family<List<MessageEntity>, String>((
  ref,
  roomId,
) {
  return ref.read(watchMessagesUseCaseProvider).call(roomId);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(supabaseClientProvider));
});

// Use cases providers

final watchMessagesUseCaseProvider = Provider<WatchMessagesUseCase>((ref) {
  return WatchMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final markMessagesAsReadUseCaseProvider = Provider<MarkMessagesAsReadUseCase>((ref) {
  return MarkMessagesAsReadUseCase(ref.watch(chatRepositoryProvider));
});