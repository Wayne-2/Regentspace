import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Future<void> sendInvite(BuildContext context) async {
  final emailController = TextEditingController();

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Regentspace Invitation",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 10),
                  Text("We would send an invitation link to the provided Email below",
                      textAlign: TextAlign.center, style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter receiver's email",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(116, 6, 144, 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(
                                content: Text('Please enter an email'), backgroundColor: Color(0xFF740690)));
                          }
                          return;
                        }
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (context.mounted) showLoadingPopup(context);
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) Navigator.pop(context);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Invite sent to $email (static demo)', style: TextStyle(fontFamily: 'DMSans', fontSize: 12)),
                              backgroundColor: const Color(0xFF740690)));
                        }
                      },
                      child: Text("Send", style: TextStyle(fontFamily: 'DMSans', fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showLoadingPopup(BuildContext context) {
  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LoadingAnimationWidget.fourRotatingDots(size: 60, color: const Color.fromRGBO(209, 69, 255, 1)),
        ),
      ),
    ),
  );
}
