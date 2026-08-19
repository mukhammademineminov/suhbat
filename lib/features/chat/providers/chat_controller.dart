import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suhbat/features/chat/providers/chat_provider.dart';

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);

class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // no-op
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sendMessageUseCaseProvider).call(
            roomId: roomId,
            content: text,
          );
    });
  }

  Future<void> markAsRead(String roomId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(markMessagesAsReadUseCaseProvider).call(roomId);
    });
  }
}