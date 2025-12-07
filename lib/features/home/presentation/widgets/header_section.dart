import 'package:flutter/material.dart';
import '../../data/models/home_model.dart';
import 'package:tifli/core/constants/icons.dart';
import 'package:tifli/features/navigation/app_router.dart';

class AppColors {
  static const Color pink = Color(0xFFb03a57);
  static const Color darkText = Color(0xFF111111);
  static const Color grayText = Color(0xFF666666);
  static const Color card = Color(0xFFFFFFFF);
  static const Color lightBg = Color(0xFFFDF5F7);
  static const Color softBorder = Color(0xFFE9E9E9);
  static const Color pinkAccentBg = Color(0xFFF9ECEE);
  static const Color lightGray = Color(0xFFF1F1F1);
}

class HeaderCard extends StatelessWidget {
  final Profile profile;
  final List<Stat> stats;

  const HeaderCard({super.key, required this.profile, required this.stats});

  @override
  Widget build(BuildContext context) {
    final avatar =
        (profile.avatarUrl.isNotEmpty && profile.avatarUrl.startsWith('http'))
        ? NetworkImage(profile.avatarUrl)
        : const AssetImage('assets/images/baby3.jpg') as ImageProvider;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        image: DecorationImage(image: avatar, fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.06),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 22, backgroundImage: avatar),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HeaderNameBlock(
                        name: profile.name,
                        age: profile.ageDescription,
                        bloodType: profile.bloodType,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Navigate to Baby Profile screen (same as drawer link)
                        Navigator.of(context).pushNamed(AppRoutes.babyProfile);
                      },
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        title: stats.isNotEmpty ? stats[0].value : '--',
                        subtitle: stats.isNotEmpty ? stats[0].subtitle : '',
                        icon: AppIcons.time,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatChip(
                        title: stats.length > 1 ? stats[1].value : '--',
                        subtitle: stats.length > 1 ? stats[1].subtitle : '',
                        icon: AppIcons.feeding,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderNameBlock extends StatelessWidget {
  final String name;
  final String age;
  final String? bloodType;
  const HeaderNameBlock({
    super.key,
    required this.name,
    required this.age,
    this.bloodType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          age,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        if (bloodType != null && bloodType!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Blood type: ${bloodType!}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class StatChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const StatChip({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(51, 220, 66, 110),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
