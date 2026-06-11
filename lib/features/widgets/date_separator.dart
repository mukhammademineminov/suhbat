import 'package:flutter/material.dart';


class DateSeparator extends StatelessWidget {
  final DateTime date;
  
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (date == today) {
      label = 'Today';
    } else if (date == yesterday) {
      label = 'Yesterday';
    } else {
      label = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }

    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}