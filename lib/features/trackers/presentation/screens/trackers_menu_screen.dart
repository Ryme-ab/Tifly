import 'package:flutter/material.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class TrackersMenuScreen extends StatelessWidget {
  const TrackersMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Track'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 30,
            children: [
              _buildTrackerButton(
                context,
                icon: Icons.bedtime,
                label: "Sleep",
                color: const Color(0xffffcdd2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepPage()),
                  );
                },
              ),
              _buildTrackerButton(
                context,
                icon: Icons.fitness_center,
                label: "Growth",
                color: const Color(0xfff8bbd0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GrowthPage()),
                  );
                },
              ),
              _buildTrackerButton(
                context,
                icon: Icons.local_drink,
                label: "Feeding",
                color: const Color(0xfffff9c4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FoodPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: const Color(0xffb03a57), size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
