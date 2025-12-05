import 'package:flutter/material.dart';
import 'package:tifli/core/constants/icons.dart';
import 'header_section.dart';

class LogsSection extends StatelessWidget {
  const LogsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _LogCard(icon: AppIcons.feedingBottle, bgColor: const Color(0xFFEAF3FF), title: "Feeding", value: "Tap to log", onTap: () => _go(context, 'feeding')),
      _LogCard(icon: AppIcons.sleep, bgColor: const Color(0xFFF3E9FF), title: "Sleep", value: "Tap to log", onTap: () => _go(context, 'sleep')),
      _LogCard(icon: AppIcons.diaper, bgColor: const Color(0xFFFFF8E1), title: "Diaper", value: "Tap to log", onTap: () => _go(context, 'diaper')),
      _LogCard(icon: AppIcons.temperature, bgColor: const Color(0xFFFFE8E8), title: "Temp", value: "Tap to log", onTap: () => _go(context, 'temperature')),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quick Actions', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
      const SizedBox(height: 16),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5, children: items),
    ]);
  }

  

  void _go(BuildContext context, String type) {
    // Simple routing: map types to existing screens if available
    switch (type) {
      case 'feeding':
        Navigator.of(context).pushNamed('/logs/feeding');
        break;
      case 'sleep':
        Navigator.of(context).pushNamed('/logs/sleep');
        break;
      case 'diaper':
        Navigator.of(context).pushNamed('/logs/diaper');
        break;
      case 'temperature':
        Navigator.of(context).pushNamed('/logs/temperature');
        break;
      default:
        Navigator.of(context).pushNamed('/logs');
    }
  }
}

// Removed dynamic mapping; using fixed buttons only.

class _LogCard extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _LogCard({required this.icon, required this.bgColor, required this.title, required this.value, this.onTap});

  Color _getIconColor(Color bgColor) {
    if (bgColor == const Color(0xFFEAF3FF)) return const Color(0xFF1E88E5);
    if (bgColor == const Color(0xFFF3E9FF)) return const Color(0xFF7C4DFF);
    if (bgColor == const Color(0xFFFFF8E1)) return const Color(0xFFFBC02D);
    if (bgColor == const Color(0xFFFFE8E8)) return const Color.fromARGB(255, 181, 99, 132);
    return AppColors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: _getIconColor(bgColor), size: 26),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
        ]),
      ]),
    ),
    );
  }
}