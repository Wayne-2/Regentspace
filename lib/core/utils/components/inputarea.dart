import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Inputarea extends StatelessWidget {
  const Inputarea({super.key, required this.prefixicon, required this.label, required this.placeholder, required this.suffixicon, required this.obscuretext});
  final String prefixicon;
  final String label;
  final String placeholder;
  final String suffixicon;
  final bool obscuretext;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: Color.fromRGBO(158, 158, 158, 0.363))
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              prefixicon,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 15,),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color.fromRGBO(32, 19, 11, 1))),
                      SizedBox(height: 3,),
                      SizedBox(
                        width: 195,
                        height: 20,
                        child: TextField(
                          obscureText: obscuretext,
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: placeholder,
                            hintStyle: TextStyle(fontSize: 15, color: Color.fromRGBO(84, 76, 76, 0.9)),
                          ),
                        ),
                      )
                  ],),
                  SvgPicture.asset(
                    suffixicon,
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}