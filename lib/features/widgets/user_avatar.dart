import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? username;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.username,
    this.radius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      child: Text(
        (username?.isNotEmpty ?? false) ? username![0].toUpperCase() : '?',
      ),
    );
    if (onTap == null) {
      return avatar;
    } else {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }
  }
}
