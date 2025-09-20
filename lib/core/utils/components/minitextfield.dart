import 'package:flutter/material.dart';

class Minitextfield extends StatelessWidget {
  const Minitextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            width: 53,
            height: 64,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                color: Color.fromRGBO(175, 175, 175, 1),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: TextField(
                obscureText: true,
                maxLength: 1,
                decoration: InputDecoration(
                  border: InputBorder.none, // This line is also invalid and should be fixed or removed
                  hintText: '',
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  counterText: ""
                  
                ),
              ),
            ),
          );
  }
}