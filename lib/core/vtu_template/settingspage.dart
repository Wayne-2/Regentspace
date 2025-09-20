
import 'package:flutter/material.dart';


class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final Color darkBlue = Color(0xFF0B3C6F);
  final Color balanceCardColor = Color(0xFF7063E4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(23, 24, 23, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    ]
                )
            )
        )
    );
  }
}