import 'dart:math';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 40,
  });

  Color _generateColor(String name) {
    final random = Random(name.hashCode);
    final hue = random.nextDouble() * 360;
    return HSLColor.fromAHSL(0.7, hue, 0.6, 0.6).toColor();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _generateColor(name);
    final initials = _getInitials(name);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(fontFamily: 'DMSans', 
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
