import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Transactiontile extends StatelessWidget {
  const Transactiontile({super.key, required this.financialactivity, required this.date, required this.amount, required this.cashstatus});
  final String financialactivity;
  final String date;
  final String amount;
  final String cashstatus;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.37),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(0, 0), // changes position of shadow
              ),
            ]
          ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
                 children: [
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/upcash.svg',
                            width: 23,
                            height: 23,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(financialactivity, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color.fromRGBO(0, 0, 0, 1),)),
                            Text(date, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13, color: const Color.fromRGBO(0, 0, 0, 0.54)),),
                          ],
                        ),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(amount, style: TextStyle(fontWeight: FontWeight.w600, color: const Color.fromARGB(255, 0, 0, 0), fontSize: 13),), 
                            Text(cashstatus, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13, color: Color.fromRGBO(0, 0, 0, 1)),),
                          ],
                        ),
                      ],
                    ),
                  ),
                 ]),
      ),
    );
  }
}