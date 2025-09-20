import 'package:flutter/material.dart';

class ProfileOptionNewTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget leading;

  const ProfileOptionNewTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D3A70),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_sharp,
                  color: Color(0xFF1D3A70), size: 10),
            ],
          ),
        ),
      ),
    );
  }
}
