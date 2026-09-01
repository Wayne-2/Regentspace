import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Overview extends StatelessWidget {
  const Overview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(108, 0, 144, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Balance', style: TextStyle(color: Color.fromRGBO(215, 215, 215, 1), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('N 2,554,000.00', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(width: 8),
              SvgPicture.asset('assets/icons/view.svg', width: 18, height: 18),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Money Point', style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              SvgPicture.asset('assets/icons/copy.svg', width: 14, height: 14),
              const SizedBox(width: 6),
              const Text('1100326447', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}