import 'dart:io';
import 'package:flutter/material.dart';


class LogopageTemplate extends StatelessWidget {
  const LogopageTemplate({
    super.key,
    required this.selectedImagePath,
    required this.appName,
    required this.appNameColor,
  });

  final String? selectedImagePath;
  final String appName;
  final Color appNameColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.transparent,
          child: selectedImagePath == null
              ? Image.asset('assets/addLogo.png')
              : Image.file(File(selectedImagePath!)),
        ),
        Text(
          appName,
          style: TextStyle(
            fontSize: 17,
            color: appNameColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
