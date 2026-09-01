import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Static UI only — no file upload / API / Supabase.

class Regentcanva extends StatefulWidget {
  const Regentcanva({super.key});

  @override
  State<Regentcanva> createState() => _RegentcanvaState();
}

class _RegentcanvaState extends State<Regentcanva> {
  String appName = 'Input app name';
  final _textEditingController = TextEditingController();

  Color bgColor = const Color.fromARGB(255, 255, 247, 234);
  Color appNameColor = const Color.fromARGB(204, 0, 0, 0);
  Color primaryapptheme = const Color.fromARGB(255, 250, 182, 144);
  Color iconthemeColor = const Color.fromARGB(204, 0, 0, 0);

  // Mock image paths — static demo (no picker)
  String? _selectedImagePath;
  String? _selectedBgImagePath;

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image upload disabled — static UI demo'), backgroundColor: Color(0xFF740690)),
    );
  }

  void _pickDashbImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Background upload disabled — static UI demo'), backgroundColor: Color(0xFF740690)),
    );
  }

  void _showColorPicker(Color current, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(pickerColor: current, onColorChanged: onChanged, showLabel: true, pickerAreaHeightPercent: 0.8),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }

  void _saveUserChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved config for "$appName" (static demo)'), backgroundColor: const Color(0xFF740690)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Canva Studio', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview section — static
            Flexible(
              flex: 7,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryapptheme.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard_customize, size: 48, color: iconthemeColor),
                    const SizedBox(height: 12),
                    Text(appName, style: TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w700, color: appNameColor)),
                    const SizedBox(height: 6),
                    Text('Preview — static UI', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 14),
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryapptheme.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('App preview area', style: TextStyle(fontFamily: 'DMSans', color: primaryapptheme, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text('Tap on the page to preview in full', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Colors.black54)),
            Flexible(
              flex: 6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        labelText: 'App Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) => setState(() => appName = v.isEmpty ? 'Input app name' : v),
                    ),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _colorButton('BG Color', bgColor, (c) => setState(() => bgColor = c)),
                      _colorButton('Name Color', appNameColor, (c) => setState(() => appNameColor = c)),
                      _colorButton('Primary Theme', primaryapptheme, (c) => setState(() => primaryapptheme = c)),
                      _colorButton('Icon Color', iconthemeColor, (c) => setState(() => iconthemeColor = c)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Logo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDashbImage,
                          icon: const Icon(Icons.wallpaper),
                          label: const Text('Pick BG'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveUserChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF740690),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Save Changes', style: TextStyle(fontFamily: 'DMSans', color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(String label, Color color, ValueChanged<Color> onChanged) {
    return GestureDetector(
      onTap: () => _showColorPicker(color, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }
}
