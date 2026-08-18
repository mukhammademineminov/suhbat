import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/core/providers/supabase_provider.dart';
import 'package:suhbat/features/chat/data/chat_repository_impl.dart';
import 'package:suhbat/features/chat/data/message.dart';
import 'package:suhbat/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(supabaseClientProvider));
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, roomId) {
  return ref.read(chatRepositoryProvider).messagesStream(roomId);
});