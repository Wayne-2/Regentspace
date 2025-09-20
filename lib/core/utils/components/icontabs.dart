import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Icontabs extends StatelessWidget {
  const Icontabs({super.key, required this.icon, required this.label});
  final String icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
        Container(
          width: 63,
          height: 61,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 4), // changes position of shadow
              ),
            ]
          ),
          child: Center(
            child: SvgPicture.asset(
                      icon,
                      width: 24,
                      height: 24,
                    ),
          ),
        ),
        SizedBox(height: 6,),
        Text(label, style: TextStyle(color: Color.fromRGBO(62, 62, 62, 1), fontSize: 12, fontWeight: FontWeight.bold))
      ]
    );
  }
}