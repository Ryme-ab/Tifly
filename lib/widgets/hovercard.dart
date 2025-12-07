import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HoverCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const HoverCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<HoverCard> createState() => HoverCardState();
}

class HoverCardState extends State<HoverCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: hovering ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(hovering ? 0.12 : 0.05),
                  blurRadius: hovering ? 16 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // ICON BUBBLE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // LABEL
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff323232),
                    ),
                  ),
                ),
                // ARROW
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
