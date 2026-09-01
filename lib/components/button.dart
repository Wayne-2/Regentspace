import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(108, 0, 144, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontFamily: 'DMSans', 
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}