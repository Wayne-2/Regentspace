import 'package:flutter/material.dart';

class Usageinfo extends StatelessWidget {
  const Usageinfo({
    super.key,
    required this.amount,
    required this.rating,
    required this.servicetype,
    required this.fontsize
  });

  final String servicetype;
  final String rating;
  final String amount;
  final double fontsize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(amount,
            style: TextStyle(fontSize: fontsize, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(rating,
            style: TextStyle(
                fontSize: fontsize, fontWeight: FontWeight.w600, color: Colors.red)),
        const SizedBox(height: 2),
        Text(servicetype,
            style: TextStyle(fontSize: fontsize, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
