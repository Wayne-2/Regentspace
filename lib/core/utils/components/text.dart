import 'package:flutter/material.dart';

class Textmedium extends StatelessWidget {
  const Textmedium({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(height:1.3, color: Color.fromRGBO(84, 76, 76, 0.9), fontSize: 16, fontWeight: FontWeight.w500));
  }
}
class Textlarge extends StatelessWidget {
  const Textlarge({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Color.fromRGBO(32, 19, 11, 1), fontSize: 24, fontWeight: FontWeight.w600));
  }
}