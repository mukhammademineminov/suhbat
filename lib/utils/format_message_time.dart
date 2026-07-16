
String formatMessageTime(DateTime? messageTime) {
  if (messageTime == null) return '';
  final now = DateTime.now().toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final msgLocal = messageTime.toLocal();
  final msgDate = DateTime(msgLocal.year, msgLocal.month, msgLocal.day);

  if (msgDate == today) {
    final hour = msgLocal.hour.toString().padLeft(2, '0');
    final minute = msgLocal.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  if (msgDate == yesterday) {
    return 'Yesterday';
  }

  if (msgLocal.year == now.year) {
    final day = msgLocal.day.toString().padLeft(2, '0');
    final month = msgLocal.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  final day = msgLocal.day.toString().padLeft(2, '0');
  final month = msgLocal.month.toString().padLeft(2, '0');
  final year = msgLocal.year;
  return '$day.$month.$year';
}