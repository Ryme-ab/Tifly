import 'package:flutter/material.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/schedules/presentation/screens/appointments_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/medicine_schedule_screen.dart';
import 'package:tifli/features/schedules/presentation/screens/meal_planner_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/widgets/hovercard.dart';
import 'package:tifli/l10n/app_localizations.dart';

class SchedMenuScreen extends StatelessWidget {
  const SchedMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(title: l10n.schedule),
        backgroundColor: AppColors.backgroundLight,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 30),

            HoverCard(
              label: l10n.appointments,
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
              label: l10n.medicineSchedule,
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
              label: l10n.mealPlanner,
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
  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.yourBabysSchedule,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xff2e2e2e),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.manageDoctorVisits,
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }
}
