import 'package:flutter/material.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/widgets/hovercard.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/l10n/app_localizations.dart';

class TrackersMenuScreen extends StatelessWidget {
  const TrackersMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.track),
      backgroundColor: AppColors.backgroundLight,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trackYourBabyEasily,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff2e2e2e),
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  l10n.monitorSleepGrowthFeeding,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ---------- FULL-WIDTH TRACKER CARDS ----------
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  HoverCard(
                    icon: Icons.bedtime,
                    label: l10n.sleep,
                    gradient: const [Color(0xfffde2e4), Color(0xffffb5c2)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SleepPage()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  HoverCard(
                    icon: Icons.fitness_center,
                    label: l10n.growth,
                    gradient: const [Color(0xffe8def8), Color(0xffd2b5f0)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GrowthPage()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  HoverCard(
                    icon: Icons.local_drink,
                    label: l10n.feeding,
                    gradient: const [Color(0xfffff4c2), Color(0xfffce69f)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodTrackerScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
