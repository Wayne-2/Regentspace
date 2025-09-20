import 'dart:io';
import 'package:flutter/material.dart';
import 'package:newregentspace/core/src/canva/templates/finances_template.dart';
import 'package:newregentspace/core/src/canva/templates/home_page_template.dart';
import 'package:newregentspace/core/src/canva/templates/settings_template.dart';

class PreviewSection extends StatelessWidget {
  final String appName;
  final Color myColor;
  final Color appNameColor;
  final String? selectedImagePath;
  final String? selectedBgImagePath;
  final Color primaryapptheme;
  final Color homePagebgColor;

  const PreviewSection({
    super.key,
    required this.appName,
    required this.myColor,
    required this.appNameColor,
    required this.selectedImagePath,
    required this.selectedBgImagePath,
    required this.primaryapptheme,
    required this.homePagebgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.53,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 15),
        children: [
          const SizedBox(width: 20),
          // Launcher page
          Container(
            width: 195,
            height: 351,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: myColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  child: selectedImagePath == null
                      ? Image.asset('assets/addLogo.png')
                      : Image.file(File(selectedImagePath!)),
                ),
                Text(appName,
                    style: TextStyle(
                        fontSize: 17,
                        color: appNameColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // HomePage
          Container(
            width: 195,
            height: 351,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: homePagebgColor,
            ),
            child: HomePageTemplate(
              primaryapptheme: primaryapptheme,
              selectedBgImagePath: selectedBgImagePath,
            ),
          ),
          const SizedBox(width: 20),
          // Finances
          Container(
            width: 195,
            height: 351,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: homePagebgColor,
            ),
            child: FinancesTemplate(primaryapptheme: primaryapptheme),
          ),
          const SizedBox(width: 20),
          // Settings
          Container(
            width: 195,
            height: 351,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: homePagebgColor,
            ),
            child: const SettingsTemplate(),
          ),
        ],
      ),
    );
  }
}
