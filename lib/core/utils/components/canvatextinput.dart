import 'package:flutter/material.dart';

class Canvatextinput extends StatelessWidget {
  const Canvatextinput({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
            width: MediaQuery.of(context).size.width*0.45,
            height: 38,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border.all(
                color: Color.fromRGBO(175, 175, 175, 1),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none, // This line is also invalid and should be fixed or removed
                  hintText: label,
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),  
                ),
              ),
            ),
          );
  }
}