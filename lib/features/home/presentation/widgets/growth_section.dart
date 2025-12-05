import 'package:flutter/material.dart';
import '../models/home_models.dart';

class GrowthSection extends StatelessWidget {
  final GrowthSummary? summary;
  const GrowthSection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Growth', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            _MetricCard(title: 'Height', value: summary!.height ?? '--', icon: Icons.height),
            const SizedBox(width: 12),
            _MetricCard(title: 'Weight', value: summary!.weight ?? '--', icon: Icons.scale),
            const SizedBox(width: 12),
            _MetricCard(title: 'Head', value: summary!.headCircumference ?? '--', icon: Icons.straighten),
          ],
        ),
        const SizedBox(height: 6),
        Text('Last update: ${summary!.date}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _MetricCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Color(0xFF9B003D)), const SizedBox(width: 6), Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87))]),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
