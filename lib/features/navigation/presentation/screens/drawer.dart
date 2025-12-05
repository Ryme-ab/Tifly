import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:tifli/features/navigation/presentation/widgets/drawer_footer.dart';
import 'package:tifli/features/logs/presentation/screens/feeding_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/medication_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/sleeping_logs_screen.dart';
import 'package:tifli/features/profiles/presentation/screens/my_babies.dart';
import 'package:tifli/features/schedules/presentation/screens/checklist_screen.dart';

class Tiflidrawer extends StatelessWidget {
  static const Color primary = Color(0xFFBA224D);

  const Tiflidrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ---------- HEADER ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.child_care, size: 28, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        "Tifli",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ---------- MENU ITEMS ----------
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  menuItem(
                    icon: Icons.home_outlined,
                    title: "Home",
                    onTap: () => Navigator.pushNamed(context, "/home"),
                  ),

                  menuItem(
                    icon: Icons.person_outline,
                    title: "Baby Profiles",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Provider<AppBarConfig>(
                          create: (_) => AppBarConfig(),
                          child: const MyBabiesPage(),
                        ),
                      ),
                    ),
                  ),

                  menuItem(
                    icon: Icons.local_drink_outlined,
                    title: "Feeding Log",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Provider<AppBarConfig>(
                          create: (_) => AppBarConfig(),
                          child: const FeedingLogsScreen(),
                        ),
                      ),
                    ),
                  ),

                  menuItem(
                    icon: Icons.nights_stay_outlined,
                    title: "Sleep Log",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Provider<AppBarConfig>(
                          create: (_) => AppBarConfig(),
                          child: const SleepingLogsScreen(),
                        ),
                      ),
                    ),
                  ),

                  menuItem(
                    icon: Icons.show_chart_outlined,
                    title: "Medication Tracking",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Provider<AppBarConfig>(
                          create: (_) => AppBarConfig(),
                          child: const MedicationsScreen(),
                        ),
                      ),
                    ),
                  ),

                  menuItem(
                    icon: Icons.check_circle_outline,
                    title: "Checklist",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Provider<AppBarConfig>(
                          create: (_) => AppBarConfig(),
                          child: const ChecklistPage(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 20),

                  menuItem(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    onTap: () => Navigator.pushNamed(context, "/settings"),
                  ),

                  menuItem(
                    icon: Icons.help_outline,
                    title: "Help & About",
                    onTap: () => Navigator.pushNamed(context, "/help"),
                  ),

                  menuItem(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () {
                      // TODO: Add logout logic
                    },
                  ),
                ],
              ),
            ),

            // ---------- BOTTOM AREA ----------
            const DrawerFooter(),
          ],
        ),
      ),
    );
  }

  // MENU ITEM
  Widget menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
