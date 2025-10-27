import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newregentspace/core/utils/auth_page/loadingscreen.dart';
import 'package:newregentspace/core/utils/components/button.dart';
import 'package:newregentspace/core/utils/components/minitextfield.dart';
import 'package:newregentspace/core/utils/components/text.dart';

class Verificationpage extends StatefulWidget {
  const Verificationpage({super.key});

  @override
  State<Verificationpage> createState() => _VerificationpageState();
}

class _VerificationpageState extends State<Verificationpage> {
  // Controllers
  final TextEditingController _field1 = TextEditingController();
  final TextEditingController _field2 = TextEditingController();
  final TextEditingController _field3 = TextEditingController();
  final TextEditingController _field4 = TextEditingController();

  // Focus nodes for automatic movement
  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  String getOtp() =>
      _field1.text + _field2.text + _field3.text + _field4.text;

  @override
  void dispose() {
    // Clean up
    _field1.dispose();
    _field2.dispose();
    _field3.dispose();
    _field4.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_sharp),
        ),
        title: const Text(
          'Verify account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          children: [
            const Textmedium(
              text:
                  'To verify your account, please enter the 4-digit OTP sent via email below to proceed.',
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Minitextfield(
                  controller: _field1,
                  focusNode: _focus1,
                  nextFocusNode: _focus2,
                ),
                const SizedBox(width: 15),
                Minitextfield(
                  controller: _field2,
                  focusNode: _focus2,
                  nextFocusNode: _focus3,
                  prevFocusNode: _focus1,
                ),
                const SizedBox(width: 15),
                Minitextfield(
                  controller: _field3,
                  focusNode: _focus3,
                  nextFocusNode: _focus4,
                  prevFocusNode: _focus2,
                ),
                const SizedBox(width: 15),
                Minitextfield(
                  controller: _field4,
                  focusNode: _focus4,
                  prevFocusNode: _focus3,
                ),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                final otp = getOtp();
                if (otp.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter full OTP')),
                  );
                  return;
                }
                // ignore: avoid_print
                print('OTP entered: $otp');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const Loadingscreen()),
                );
              },
              child: const Button(label: 'Verify'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Textmedium(text: "Didn't receive OTP?"),
                const SizedBox(width: 3),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Center(
                          child: Text(
                            'OTP resent!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      color: Color.fromRGBO(133, 99, 188, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
