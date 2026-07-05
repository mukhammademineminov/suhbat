
String formatMessageTime(DateTime? messageTime) {
  if (messageTime == null) return '';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final msgDate = DateTime(messageTime.year, messageTime.month, messageTime.day);

  if (msgDate == today) {
    final hour = messageTime.hour.toString().padLeft(2, '0');
    final minute = messageTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  if (msgDate == yesterday) {
    return 'Yesterday';
  }
  
  if (messageTime.year == now.year) {
    final day = messageTime.day.toString().padLeft(2, '0');
    final month = messageTime.month.toString().padLeft(2, '0');
    return '$day.$month';
  }
  
  final day = messageTime.day.toString().padLeft(2, '0');
  final month = messageTime.month.toString().padLeft(2, '0');
  final year = messageTime.year;
  return '$day.$month.$year';
}