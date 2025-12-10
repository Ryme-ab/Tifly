import 'package:flutter/material.dart';
import '../../data/models/home_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/souvenires/presentation/screens/gallery_screen.dart';
import 'package:tifli/l10n/app_localizations.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  const MemoryCard({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final imageProvider = memory.imageUrl.startsWith('http')
        ? NetworkImage(memory.imageUrl)
        : AssetImage(memory.imageUrl) as ImageProvider;
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.center,
            colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memory.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                memory.date,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryList extends StatelessWidget {
  final List<Memory> memories;
  const MemoryList({super.key, required this.memories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: memories.map((m) => MemoryCard(memory: m)).toList(),
      ),
    );
  }
}

class MemoriesSection extends StatelessWidget {
  final List<Memory> memories;
  const MemoriesSection({super.key, required this.memories});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasItems = memories.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.memories,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            if (hasItems)
              InkWell(
                onTap: () {
                  final childId =
                      context.read<ChildSelectionCubit>().selectedChildId ?? '';
                  if (childId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.pleaseSelectBaby),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MemoriesPage(childId: childId, userId: ''),
                    ),
                  );
                },
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B003D),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasItems)
          _EmptyMemories(
            title: 'No memories yet',
            subtitle: 'Capture a moment to start your gallery',
            buttonText: 'Open Gallery',
            icon: Icons.photo_camera,
            onTap: () {
              final childId =
                  context.read<ChildSelectionCubit>().selectedChildId ?? '';
              if (childId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a baby first')),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MemoriesPage(childId: childId, userId: ''),
                ),
              );
            },
          )
        else
          MemoryList(memories: memories),
      ],
    );
  }
}

class _EmptyMemories extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final VoidCallback onTap;
  const _EmptyMemories({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: const Color(0xFF9B003D), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B003D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTap,
            child: const Text(
              'Open Gallery',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
