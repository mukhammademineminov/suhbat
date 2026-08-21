import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suhbat/features/direct_message/data/dm_repository.dart';
import 'package:suhbat/features/widgets/date_separator.dart';
import 'package:suhbat/features/widgets/message_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/features/chat/domain/entities/message_entity.dart';

class MessageList extends StatelessWidget {
  final List<dynamic> items;
  final ScrollController scrollController;

  const MessageList({
    super.key,
    required this.items,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is DateTime) {
          return DateSeparator(date: item);
        }

        final message = item as MessageEntity;
        final isMe = message.userId == currentUserId;

        final isSameAsPrevious =
            index < items.length - 1 &&
            items[index + 1] is MessageEntity &&
            (items[index + 1] as MessageEntity).userId == message.userId;

        return MessageBubble(
          key: ValueKey(message.id),
          content: message.content,
          createdAt: message.createdAt,
          username: message.username,
          isRead: message.isRead,
          isMe: isMe,
          isSameAsPrevious: isSameAsPrevious,
          userId: message.userId,
          onAvatarTap: () async {
            if (isMe) return;
            final conversationId =
                await DmRepository().getOrCreateConversation(message.userId);
            if (!context.mounted) return;
            GoRouter.of(context).push(
              '/dm/$conversationId/${Uri.encodeComponent(message.username ?? '')}',
            );
          },
        );
      },
    );
  }
}