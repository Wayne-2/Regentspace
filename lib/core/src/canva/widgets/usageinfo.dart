import 'package:flutter/material.dart';

class Usageinfo extends StatelessWidget {
  const Usageinfo({
    super.key,
    required this.amount,
    required this.rating,
    required this.servicetype,
  });

  final String servicetype;
  final String rating;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(amount,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(rating,
            style: const TextStyle(
                fontSize: 8, fontWeight: FontWeight.w600, color: Colors.red)),
        const SizedBox(height: 2),
        Text(servicetype,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
