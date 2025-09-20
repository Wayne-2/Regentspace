import 'package:flutter/material.dart';

class EnterPinPage extends StatefulWidget {
  final Function(String) onPinEntered;
  final bool isError;

  const EnterPinPage({super.key, required this.onPinEntered, this.isError = false});

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  String pin = '';

  void _handleKeyPress(String value) {
    if (value == 'back') {
      setState(() {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      });
    } else if (pin.length < 4) {
      setState(() {
        pin += value;
        if (pin.length == 4) {
          widget.onPinEntered(pin);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(title: 'Enter Pin'),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Text('Enter the Card Pin', style: TextStyle(fontSize: 20, color: Color(0xFF1F1F1F)),),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              bool filled = index < pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? Colors.indigo : Colors.grey.shade300,
                ),
              );
            }),
          ),
          //const Spacer(),
          const SizedBox(height: 50),
          _CustomKeypad(onKeyPressed: _handleKeyPress),
          if (widget.isError)
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Incorrect card pin. Please re-enter your pin correctly',
                      style: const TextStyle(color: Colors.red),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const _CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomKeypad extends StatelessWidget {
  final void Function(String)? onKeyPressed;

  const _CustomKeypad({this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', 'back']
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.map((key) {
              IconData? icon = key == 'back' ? Icons.backspace_outlined : null;
              return TextButton(
                onPressed: () => onKeyPressed?.call(key),
                style: TextButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: icon != null
                    ? Icon(icon, color: Colors.indigo)
                    : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
