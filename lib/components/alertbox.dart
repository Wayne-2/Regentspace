import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;
  final bool isSuccess;

  const AlertBox({
    super.key,
    required this.title,
    required this.message,
    this.isError = false,
    this.isSuccess = false,
  });

  Color get accentColor {
    if (isError) return Colors.redAccent;
    if (isSuccess) return const Color(0xFF00E676);
    return const Color(0xFFB388FF);
  }

  IconData get icon {
    if (isError) return Icons.error_outline_rounded;
    if (isSuccess) return Icons.check_circle_outline_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 249, 213, 255),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 50),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'DMSans', 
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'DMSans', 
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(fontFamily: 'DMSans', color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
