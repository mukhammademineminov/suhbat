import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? label;       
  final String? imageUrl;    
  final double radius;
  final VoidCallback? onTap;
  final double fontSize;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    required this.label,
    this.imageUrl,
    this.radius = 16,
    this.onTap,
    this.fontSize = 16,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              (label?.isNotEmpty ?? false) ? label![0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}