import 'package:flutter/material.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/schedules/presentation/screens/appointments_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/medicine_schedule_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/meal_planner_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/widgets/hovercard.dart';

class SchedMenuScreen extends StatelessWidget {
  const SchedMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Schedule'),
        backgroundColor: AppColors.backgroundLight,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),

            HoverCard(
              label: "Appointments",
              icon: Icons.calendar_month_rounded,
              gradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            HoverCard(
              label: "Medicine Schedule",
              icon: Icons.medication_rounded,
              gradient: const [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedicineScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            HoverCard(
              label: "Meal Planner",
              icon: Icons.restaurant_menu_rounded,
              gradient: const [Color(0xFFFFF1A4), Color(0xFFFFD59E)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MealPlannerScreenV2(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Your Baby's Schedule",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xff2e2e2e),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Manage doctor visits, medication reminders and daily meals.",
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }
}
