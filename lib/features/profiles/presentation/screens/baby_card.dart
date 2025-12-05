import 'package:flutter/material.dart';

class BabyCard extends StatelessWidget {
  final String name;
  final int age;
  final String imageUrl;
  final Color borderColor;

  const BabyCard({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('Age: $age'),
        ],
      ),
    );
  }
}
