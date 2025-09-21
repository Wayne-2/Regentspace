import 'package:flutter/material.dart';

class Icontabs extends StatelessWidget {
  const Icontabs({
    super.key,
    required this.icon,
    required this.label,
    required this.themecolor,
    required this.color,
    required this.height,
    required this.width,
    required this.iconsize
  });
  final IconData icon;
  final Color themecolor;
  final Color color;
  final String label;
  final double height;
  final double width;
  final double iconsize;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black12, width: 1),
            color: themecolor,
          ),
          child: Center(child: Icon(icon, size: iconsize, color: color)),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Color.fromRGBO(62, 62, 62, 1),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
