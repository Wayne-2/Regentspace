import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Inputarea extends StatelessWidget {
  const Inputarea({
    super.key,
    required this.prefixicon,
    required this.label,
    required this.placeholder,
    required this.suffixicon,
    required this.obscuretext,
    required this.controller,
  });
  final String prefixicon;
  final String label;
  final String placeholder;
  final String suffixicon;
  final bool obscuretext;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: const Color.fromRGBO(158, 158, 158, 0.30),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(prefixicon, width: 20, height: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(32, 19, 11, 1),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 22,
                    child: TextField(
                      controller: controller,
                      obscureText: obscuretext,
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: const Color.fromRGBO(32, 19, 11, 1)),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: placeholder,
                        hintStyle: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 13.5,
                          color: const Color.fromRGBO(120, 110, 110, 0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (suffixicon.isNotEmpty) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(suffixicon, width: 20, height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class InputAreaForPassword extends StatefulWidget {
  const InputAreaForPassword({
    super.key,
    required this.prefixIcon,
    required this.label,
    required this.placeholder,
    required this.controller,
  });

  final String prefixIcon;
  final String label;
  final String placeholder;
  final TextEditingController controller;

  @override
  State<InputAreaForPassword> createState() => _InputAreaForPasswordState();
}

class _InputAreaForPasswordState extends State<InputAreaForPassword> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: const Color.fromRGBO(158, 158, 158, 0.30),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(widget.prefixIcon, width: 20, height: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(32, 19, 11, 1),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 22,
                    child: TextField(
                      controller: widget.controller,
                      obscureText: isObscured,
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: const Color.fromRGBO(32, 19, 11, 1)),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 13.5,
                          color: const Color.fromRGBO(120, 110, 110, 0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  isObscured = !isObscured;
                });
              },
              child: SvgPicture.asset(
                isObscured ? "assets/icons/Eye.svg" : "assets/icons/Eye_off.svg",
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
