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
  final Color iconthemeColor;

  const PreviewSection({
    super.key,
    required this.appName,
    required this.myColor,
    required this.appNameColor,
    required this.selectedImagePath,
    required this.selectedBgImagePath,
    required this.primaryapptheme,
    required this.homePagebgColor,
    required this.iconthemeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // now 60% of screen
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 15),
        children: [
          const SizedBox(width: 20),

          /// Launcher Page
          _PreviewThumbnail(
            fullscreenContent: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.transparent,
                  child: selectedImagePath == null
                      ? Image.asset('assets/addLogo.png')
                      : Image.file(File(selectedImagePath!)),
                ),
                const SizedBox(height: 20),
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 28,
                    color: appNameColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: myColor,
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
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 17,
                    color: appNameColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          /// HomePage
          _PreviewThumbnail(
            fullscreenContent: HomePageTemplate(
              primaryapptheme: primaryapptheme,
              selectedBgImagePath: selectedBgImagePath,
              iconthemeColor: iconthemeColor,
            ),
            backgroundColor: homePagebgColor,
            child: HomePageTemplate(
              primaryapptheme: primaryapptheme,
              selectedBgImagePath: selectedBgImagePath,
              iconthemeColor: iconthemeColor,
            ),
          ),

          const SizedBox(width: 20),

          /// Finances
          _PreviewThumbnail(
            fullscreenContent:
                FinancesTemplate(primaryapptheme: primaryapptheme),
            backgroundColor: homePagebgColor,
            child: FinancesTemplate(primaryapptheme: primaryapptheme),
          ),

          const SizedBox(width: 20),

          /// Settings
          _PreviewThumbnail(
            fullscreenContent: const SettingsTemplate(),
            backgroundColor: homePagebgColor,
            child: const SettingsTemplate(),
          ),
        ],
      ),
    );
  }

  
}


class _PreviewThumbnail extends StatelessWidget {
  final Widget child;
  final Widget fullscreenContent;
  final Color backgroundColor;

  const _PreviewThumbnail({
    required this.child,
    required this.fullscreenContent,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreenDialog(context),
      child: Container(
        width: 195,
        height: 351,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor,
        ),
        child: child,
      ),
    );
  }

  void _openFullscreenDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(child: fullscreenContent),
              Positioned(
                top: 30,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
