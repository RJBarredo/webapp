import 'package:flutter/material.dart';

class StudyCard extends StatefulWidget {
  final String title;
  final String description;


  final IconData? icon;

  final VoidCallback? onTap;

  const StudyCard(
      this.title,
      this.description, {
        super.key,
        this.icon,
        this.onTap,
      });

  @override
  State<StudyCard> createState() => _StudyCardState();
}

class _StudyCardState extends State<StudyCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: hovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        curve: Curves.easeOut,
        width: isWide ? 240 : double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
          boxShadow: hovering
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Icon(
                widget.icon ?? Icons.circle, // Default placeholder icon
                size: 32,
                color: Colors.grey[700], // Neutral color to blend with UI
              ),

              const SizedBox(height: 14),


              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),


              Text(
                widget.description,
                style: TextStyle(
                  height: 1.45,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
