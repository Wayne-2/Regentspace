import 'package:flutter/material.dart';
import 'package:newregentspace/core/src/canva/extracted_widgets/functions.dart';
import 'package:newregentspace/core/src/canva/widgets/app_bar_menu.dart';
import 'package:newregentspace/core/src/canva/widgets/editable_section.dart';
import 'package:newregentspace/core/src/canva/widgets/preview_section.dart';

class Regentcanva extends StatefulWidget {
  const Regentcanva({super.key});

  @override
  State<Regentcanva> createState() => _RegentcanvaState();
}

class _RegentcanvaState extends State<Regentcanva> {
  // state
  String? _selectedImagePath;
  String? _selectedBgImagePath;
  final _textEditingController = TextEditingController();
  String appName = 'Input app name';

  Color myColor = const Color.fromARGB(255, 255, 247, 234);
  Color appNameColor = const Color.fromARGB(204, 0, 0, 0);
  Color primaryapptheme = const Color.fromARGB(255, 250, 182, 144);
  Color homePagebgColor = const Color.fromARGB(255, 255, 247, 234);

  // image pickers
  Future _pickImage() async {
    final path = await pickImageFromGallery();
    if (path == null) return;
    setState(() => _selectedImagePath = path);
  }

  Future _pickDashbImage() async {
    final path = await pickImageFromGallery();
    if (path == null) return;
    setState(() => _selectedBgImagePath = path);
  }

  // color pickers
  void _showColorPicker() => showColorPickerDialog(
        context,
        pickerColor: myColor,
        onColorChanged: (c) => setState(() => myColor = c),
      );

  void _appNameColorPicker() => showColorPickerDialog(
        context,
        pickerColor: appNameColor,
        onColorChanged: (c) => setState(() => appNameColor = c),
      );

  void _primaryAppTheme() => showColorPickerDialog(
        context,
        pickerColor: primaryapptheme,
        onColorChanged: (c) => setState(() => primaryapptheme = c),
      );

  void _homePageBgColor() => showColorPickerDialog(
        context,
        pickerColor: homePagebgColor,
        onColorChanged: (c) => setState(() => homePagebgColor = c),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBarMenu(),
      body: Column(
        children: [
          PreviewSection(
            appName: appName,
            myColor: myColor,
            appNameColor: appNameColor,
            selectedImagePath: _selectedImagePath,
            selectedBgImagePath: _selectedBgImagePath,
            primaryapptheme: primaryapptheme,
            homePagebgColor: homePagebgColor,
          ),
          Expanded(
            child: EditableSection(
              textEditingController: _textEditingController,
              onAppNameChanged: () => setState(() => appName = _textEditingController.text),
              onPickImage: _pickImage,
              onPickBgImage: _pickDashbImage,
              onPickAppNameColor: _appNameColorPicker,
              onPickBackgroundColor: _showColorPicker,
              onPickPrimaryTheme: _primaryAppTheme,
              onPickHomeBgColor: _homePageBgColor,
              appNameColor: appNameColor,
              myColor: myColor,
              primaryapptheme: primaryapptheme,
              homePagebgColor: homePagebgColor,
            ),
          ),

        ],
      ),
    );
  }
}