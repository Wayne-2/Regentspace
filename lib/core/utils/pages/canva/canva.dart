import 'package:flutter/material.dart';
import 'package:newregentspace/core/utils/pages/canva/extracted_widgets/functions.dart';
import 'package:newregentspace/core/utils/pages/canva/widgets/app_bar_menu.dart';
import 'package:newregentspace/core/utils/pages/canva/widgets/editable_section.dart';
import 'package:newregentspace/core/utils/pages/canva/widgets/preview_section.dart';

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
  Color iconthemeColor = const Color.fromARGB(204, 0, 0, 0);
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
  void _iconcolor() => showColorPickerDialog(
        context,
        pickerColor: iconthemeColor,
        onColorChanged: (c) => setState(() => iconthemeColor = c),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBarMenu(),
      body: Column(
        children: [
          
          Flexible(
          flex: 7, // 6 out of 10 → 60%
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 0),
            child:  PreviewSection(
            appName: appName,
            myColor: myColor,
            appNameColor: appNameColor,
            selectedImagePath: _selectedImagePath,
            selectedBgImagePath: _selectedBgImagePath,
            primaryapptheme: primaryapptheme,
            homePagebgColor: homePagebgColor,
            iconthemeColor: iconthemeColor
          ),
          ),
        ),
         Text(
            'Tap on the page to preview in full',
            style: TextStyle(fontSize: 10),),
          Flexible(
          flex: 3, // 4 out of 10 → 40%
          child: EditableSection(
            textEditingController: _textEditingController,
            onAppNameChanged: () =>
                setState(() => appName = _textEditingController.text),
            onPickImage: _pickImage,
            onPickBgImage: _pickDashbImage,
            onPickAppNameColor: _appNameColorPicker,
            onPickBackgroundColor: _showColorPicker,
            selectedBgImagePath: _selectedBgImagePath,
            onPickPrimaryTheme: _primaryAppTheme,
            onPickHomeBgColor: _homePageBgColor,
            onPickIconThemeColor:_iconcolor,
            appNameColor: appNameColor,
            myColor: myColor,
            primaryapptheme: primaryapptheme,
            homePagebgColor: homePagebgColor,
            iconthemeColor: iconthemeColor,
          ),
        ),

        ],
      ),
    );
  }
}