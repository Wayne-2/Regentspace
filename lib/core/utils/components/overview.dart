import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Overview extends StatelessWidget {
  const Overview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      width:double.infinity,
      height: 141,
      decoration:BoxDecoration(
        color: Color.fromRGBO(108, 0, 144, 1),
        borderRadius: BorderRadius.circular(12)
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Text('Available Balance', style: TextStyle(color: Color.fromRGBO(215, 215, 215, 1), fontSize: 14, fontWeight: FontWeight.w500)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('N 2,554,000.00', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              SvgPicture.asset(
                      'assets/icons/view.svg',
                      width: 16,
                      height: 16,
                    ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Money Point', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 16, fontWeight: FontWeight.normal)),
              SizedBox(width: 8),
              SvgPicture.asset(
                      'assets/icons/copy.svg',
                      width: 16,
                      height: 16,
                    ),
              SizedBox(width: 8),
              Text('1100326447', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 16, fontWeight: FontWeight.normal)),
            ],
          ),
        ]
      )
    );
  }
}