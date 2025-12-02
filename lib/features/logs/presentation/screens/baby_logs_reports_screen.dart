import 'package:flutter/material.dart';
import 'package:tifli/features/logs/presentation/screens/medication_logs_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'feeding_logs_screen.dart';
import 'sleeping_logs_screen.dart';

class BabyLogsReportsPage extends StatelessWidget {
  const BabyLogsReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFF9F6FA),
      appBar: const CustomAppBar(title: 'Logs & Reports'),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // ---------------------------------------------------------------
          // BABY DROPDOWN
          // ---------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Select Baby",
                ),
                value: "Baby 1",
                items: ["Baby 1", "Baby 2", "Baby 3"]
                    .map(
                      (baby) =>
                          DropdownMenuItem(value: baby, child: Text(baby)),
                    )
                    .toList(),
                onChanged: (value) {},
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // -------------------------------------------------------
                  // NAVIGATION BUTTONS (FEED / SLEEP / MEDS)
                  // -------------------------------------------------------
                  _LogButton(
                    icon: Icons.local_drink,
                    title: "Feeding Logs",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedingLogsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _LogButton(
                    icon: Icons.bedtime,
                    title: "Sleeping Logs",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SleepingLogsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _LogButton(
                    icon: Icons.medication_liquid,
                    title: "Medication Logs",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicationLogsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // -------------------------------------------------------
                  // ACTIVITY LOG TABLE
                  // -------------------------------------------------------
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Activity Logs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        LogTable(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // ---------------------------------------------------------------
      // BOTTOM BUTTONS
      // ---------------------------------------------------------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F6FA),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF48484A) : const Color(0xFFE5E5EA),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.description),
              label: const Text("Generate Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF56587),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.bar_chart, color: Color(0xFFF56587)),
              label: const Text(
                "View Statistics Dashboard",
                style: TextStyle(color: Color(0xFFF56587)),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================================
// CUSTOM LOG NAVIGATION BUTTON
// =======================================================================================
class _LogButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LogButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFF56587)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================================
// TABLE OF ACTIVITY LOGS
// =======================================================================================
class LogTable extends StatelessWidget {
  final logs = const [
    ["10:30 AM", "Feeding", "Completed\nBreast milk (right side)\n15 min"],
    ["09:00 AM", "Sleep", "1h 15m\nNap"],
    ["07:00 AM", "Medication", "Given\nVitamin D 0.5 ml"],
    ["06:30 AM", "Feeding", "Completed\nFormula - 120 ml"],
    ["12:00 AM", "Sleep", "7h 30m\nNight Sleep"],
    ["Yesterday\n09:00 PM", "Growth", "12 lbs 3 oz\nWeight check"],
    ["Today\n03:00 PM", "Appointment", "Scheduled\nPediatrician visit"],
  ];

  const LogTable({super.key});

  Color tagColor(String type) {
    switch (type) {
      case "Feeding":
        return const Color(0xFF6B6BFF);
      case "Sleep":
        return Colors.teal;
      case "Medication":
        return Colors.redAccent;
      case "Growth":
        return Colors.grey;
      case "Appointment":
        return Colors.orangeAccent;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(90),
        1: FixedColumnWidth(100),
        2: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: logs.map((log) {
        final color = tagColor(log[1]);
        return TableRow(
          children: [
            // TIME
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                log[0],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // TAG
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    log[1],
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // DETAILS
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                log[2],
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
