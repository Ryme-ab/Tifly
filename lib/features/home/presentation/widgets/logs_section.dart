import 'package:flutter/material.dart';
import 'package:tifli/core/constants/icons.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'header_section.dart';
import 'package:tifli/features/logs/presentation/screens/feeding_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/sleeping_logs_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/medicine_schedule_screen.dart';

class LogsSection extends StatelessWidget {
  const LogsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _LogCard(
        icon: AppIcons.sleep,
        bgColor: const Color(0xFFF3E9FF),
        title: l10n.sleep,
        value: l10n.tapToLog,
        onTap: () => _goSleep(context),
      ),
      _LogCard(
        icon: AppIcons.feedingBottle,
        bgColor: const Color(0xFFEAF3FF),
        title: l10n.feeding,
        value: l10n.tapToLog,
        onTap: () => _goFeeding(context),
      ),
      _LogCard(
        icon: Icons.show_chart_outlined,
        bgColor: const Color(0xFFFFF8E1),
        title: l10n.growth,
        value: l10n.tapToLog,
        onTap: () => _goGrowth(context),
      ),
      _LogCard(
        icon: Icons.medication_outlined,
        bgColor: const Color(0xFFFFE8E8),
        title: l10n.medication,
        value: l10n.tapToLog,
        onTap: () => _goMedication(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: items,
        ),
      ],
    );
  }

  void _goFeeding(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FeedingLogsScreen()));
  }

  void _goSleep(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SleepingLogsScreen()));
  }

  void _goGrowth(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GrowthPage()));
  }

  void _goMedication(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MedicineScreen()));
  }
}

// Removed dynamic mapping; using fixed buttons only.

class _LogCard extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _LogCard({
    required this.icon,
    required this.bgColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  Color _getIconColor(Color bgColor) {
    if (bgColor == const Color(0xFFEAF3FF)) return const Color(0xFF1E88E5);
    if (bgColor == const Color(0xFFF3E9FF)) return const Color(0xFF7C4DFF);
    if (bgColor == const Color(0xFFFFF8E1)) return const Color(0xFFFBC02D);
    if (bgColor == const Color(0xFFFFE8E8)) {
      return const Color.fromARGB(255, 181, 99, 132);
    }
    return AppColors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: _getIconColor(bgColor), size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
