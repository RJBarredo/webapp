import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final double? fontSize;

  const SectionTitle(this.title, {super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 22,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}
