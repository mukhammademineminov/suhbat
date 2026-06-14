import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final DateTime createdAt;
  final bool isMe;
  final bool isRead;
  final String? username;
  final bool isSameAsPrevious;
  final bool showUsername;

  const MessageBubble({
    super.key,
    required this.content,
    required this.createdAt, 
    required this.isMe,
    required this.isRead,
    required this.username,
    required this.isSameAsPrevious,
    this.showUsername = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                content,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    createdAt.toLocal().toString().substring(11, 16),
                    style: TextStyle(
                      fontSize: 8,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showUsername && !isSameAsPrevious)
            CircleAvatar(
              radius: 16,
              child: Text(
                (username ?? '?')[0].toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          if (isSameAsPrevious) const SizedBox(width: 32),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showUsername && !isSameAsPrevious)
                        Text(
                          username ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      if (showUsername && !isSameAsPrevious) const SizedBox(height: 4),
                      SelectableText(
                        content,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        createdAt.toLocal().toString().substring(
                          11,
                          16,
                        ),
                        style: TextStyle(
                          fontSize: 8,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
