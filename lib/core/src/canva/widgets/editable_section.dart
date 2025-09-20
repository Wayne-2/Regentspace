// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditableSection extends StatelessWidget {
  final TextEditingController textEditingController;
  final VoidCallback onPickImage;
  final VoidCallback onPickBgImage;
  final VoidCallback onPickAppNameColor;
  final VoidCallback onPickBackgroundColor;
  final VoidCallback onPickPrimaryTheme;
  final VoidCallback onPickHomeBgColor;
  final VoidCallback onAppNameChanged;

  final Color appNameColor;
  final Color myColor;
  final Color primaryapptheme;
  final Color homePagebgColor;

  const EditableSection({
    super.key,
    required this.textEditingController,
    required this.onPickImage,
    required this.onPickBgImage,
    required this.onPickAppNameColor,
    required this.onPickBackgroundColor,
    required this.onPickPrimaryTheme,
    required this.onPickHomeBgColor,
    required this.onAppNameChanged,
    required this.appNameColor,
    required this.myColor,
    required this.primaryapptheme,
    required this.homePagebgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ListView(
        children: [
          // App Name Input
          const Text('App Name',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 47,
                  color: const Color.fromRGBO(245, 245, 245, 1),
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        onPressed: () => textEditingController.clear(),
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                    style: GoogleFonts.lato(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MaterialButton(
                onPressed: onAppNameChanged,
                color: const Color.fromRGBO(108, 0, 144, 1),
                child: const Text(
                  'add',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // App Logo Picker
          const Text('App Logo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_photo_alternate,
                      color: Color.fromARGB(115, 7, 7, 7), size: 20),
                  const SizedBox(width: 6),
                  Text('Add media file', style: GoogleFonts.lato(fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: const Color.fromARGB(160, 8, 8, 8),
                onPressed: onPickImage,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // App Name Color Picker
          const Text('App Name color',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Text color', style: GoogleFonts.lato(fontSize: 14)),
              GestureDetector(
                onTap: onPickAppNameColor,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: appNameColor,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Background Color Picker
          const Text('Background color',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select background', style: GoogleFonts.lato(fontSize: 14)),
              GestureDetector(
                onTap: onPickBackgroundColor,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: myColor,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dashboard Image Picker
          const Text('Info Panel Image',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_photo_alternate,
                      color: Color.fromARGB(115, 7, 7, 7), size: 20),
                  const SizedBox(width: 6),
                  Text('Tap to change image', style: GoogleFonts.lato(fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: const Color.fromARGB(160, 8, 8, 8),
                onPressed: onPickBgImage,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary App Theme Color Picker
          const Text('Primary App Theme',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select primary color for app widget', style: GoogleFonts.lato(fontSize: 14)),
              GestureDetector(
                onTap: onPickPrimaryTheme,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primaryapptheme,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Home Page Background Color Picker
          const Text('Background color',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select background', style: GoogleFonts.lato(fontSize: 14)),
              GestureDetector(
                onTap: onPickHomeBgColor,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: homePagebgColor,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
