import 'package:flutter/material.dart';

class BabyCard extends StatelessWidget {
  final String name;
  final int age;
  final String imageUrl;
  final Color borderColor;
  final VoidCallback? onDelete;

  const BabyCard({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.borderColor,
    this.onDelete,
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
          Stack(
            children: [
              CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
              if (onDelete != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
