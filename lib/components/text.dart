import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Textmedium extends StatelessWidget {
  const Textmedium({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.body()); // 13.5 w400 secondary — conventional body
  }
}
class Textlarge extends StatelessWidget {
  const Textlarge({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.headline()); // 22 w700 primary — conventional headline
  }
}