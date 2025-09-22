import 'package:flutter/material.dart';
import 'package:newregentspace/core/vtu_template/enterpin.dart';
// Make sure this path is correct for your project

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  String amount = '';

  void _handleKeyPress(String value) {
    setState(() {
      if (value == 'back') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else if (value == '0' && amount.isEmpty) {
        return; // Prevent leading zero
      } else {
        amount += value;
      }
    });
  }

  String get formattedAmount {
    if (amount.isEmpty) return '\u20a60.00';
    final parsed = int.tryParse(amount);
    if (parsed == null) return '\u20a60.00';
    return '\u20a6${parsed.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ",")}.00';
  }

  void _navigateToEnterPin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterPinPage(
          onPinEntered: (pin) {
            // Handle pin result here
            // ignore: avoid_print
            print("Amount: ₦$amount, PIN: $pin");
          },
          isError: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(title: 'Add Money'),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'How much do you want to add to your FinPadi account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF1F1F1F)),
          ),
          const SizedBox(height: 16),
          Text(
            formattedAmount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          //const Spacer(),
          const SizedBox(height: 50),
          _CustomKeypad(onKeyPressed: _handleKeyPress),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: amount.isEmpty ? null : _navigateToEnterPin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Color(0xFFF56C2A),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.white, // Ensures white text regardless of state
              ),
              child: const Text('Next'),
            ),
          )
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
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      centerTitle: true,
      backgroundColor: Colors.white,
      //foregroundColor: Colors.black,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomKeypad extends StatelessWidget {
  final void Function(String) onKeyPressed;

  const _CustomKeypad({required this.onKeyPressed});

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
                onPressed: () => onKeyPressed(key),
                style: TextButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: icon != null
                    ? Icon(icon, color: Color(0xFF1D3A70))
                    : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF1D3A70),
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













/*import 'package:flutter/material.dart';

class AddMoneyPage extends StatefulWidget {
  final Function(String) onNext;

  const AddMoneyPage({super.key, required this.onNext});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  String amount = '';

  void _handleKeyPress(String value) {
    setState(() {
      if (value == 'back') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else if (value == '0' && amount.isEmpty) {
        return; // Prevent leading zero
      } else {
        amount += value;
      }
    });
  }

  String get formattedAmount {
    if (amount.isEmpty) return '\u20a60.00';
    final parsed = int.tryParse(amount);
    if (parsed == null) return '\u20a60.00';
    return '\u20a6${parsed.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ",")}.00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _CustomAppBar(title: 'Add Money'),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'How much do you want to add to your FinPadi account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            formattedAmount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _CustomKeypad(onKeyPressed: _handleKeyPress),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: amount.isEmpty ? null : () => widget.onNext(amount),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Next'),
            ),
          )
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
  final void Function(String) onKeyPressed;

  const _CustomKeypad({required this.onKeyPressed});

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
                onPressed: () => onKeyPressed(key),
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
*/