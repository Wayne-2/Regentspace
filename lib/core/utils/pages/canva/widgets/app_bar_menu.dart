import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSizeWidget buildAppBarMenu() {
  return AppBar(
    backgroundColor: Colors.white,
    leading: GestureDetector(
      onTap: () {
        // bottom sheet menu
      },
      child: const Icon(Icons.menu, size: 21),
    ),
    title: Text("Canvas",
        style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold)),
    actions: [
      DropdownButtonHideUnderline(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton(
            icon: const Icon(Icons.more_vert, size: 25, color: Colors.black54),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: 'Settings', child: Text('Settings')),
              DropdownMenuItem(value: 'Info', child: Text('Info')),
            ],
            onChanged: (value) {},
          ),
        ),
      ),
      const SizedBox(width: 10),
    ],
  );
}
