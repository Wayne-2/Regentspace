import 'package:flutter/material.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => ChangepasswordState();
}

class ChangepasswordState extends State<Changepassword> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _reenterController = TextEditingController();

  bool get isAllFilled =>
      _currentController.text.isNotEmpty &&
          _newController.text.isNotEmpty &&
          _reenterController.text.isNotEmpty;

  void _checkFields() {
    setState(() {}); // triggers rebuild to update Save button
  }

  @override
  void initState() {
    super.initState();
    _currentController.addListener(_checkFields);
    _newController.addListener(_checkFields);
    _reenterController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _reenterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Change Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _PasswordInputField(
              controller: _currentController,
              hintText: 'Current Password',
            ),
            const SizedBox(height: 12),
            _PasswordInputField(
              controller: _newController,
              hintText: 'New Password',
            ),
            const SizedBox(height: 12),
            _PasswordInputField(
              controller: _reenterController,
              hintText: 'Re-enter Password',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAllFilled ? () {
                  // Handle Save logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully.')),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7063E4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _PasswordInputField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Color(0xFFF6F8FB), // light background
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFC4C4C4)),
        ),
      ),
    );
  }
}

