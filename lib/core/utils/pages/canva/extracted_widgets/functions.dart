
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImageFromGallery() async {
  final imagePicked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );
  return imagePicked?.path;
}

/// Opens a Cupertino color picker dialog.
/// [pickerColor] = current color.
/// [onColorChanged] = callback when new color is chosen.
void showColorPickerDialog(
  BuildContext context, {
  required Color pickerColor,
  required ValueChanged<Color> onColorChanged,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Choose color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
