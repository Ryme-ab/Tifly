import 'package:flutter/material.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      backgroundColor: AppColors.backgroundLight,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xff2e2e2e),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage your preferences and app settings.",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // Settings Items
            _SettingItem(icon: Icons.person, label: "Account", onTap: () {}),
            const SizedBox(height: 15),

            _SettingItem(
              icon: Icons.notifications,
              label: "Notifications",
              onTap: () {},
            ),
            const SizedBox(height: 15),

            _SettingItem(icon: Icons.lock, label: "Privacy", onTap: () {}),
            const SizedBox(height: 15),

            _SettingItem(
              icon: Icons.color_lens,
              label: "Language",
              onTap: () {},
            ),
            const SizedBox(height: 15),

            _SettingItem(icon: Icons.color_lens, label: "Theme", onTap: () {}),
            const SizedBox(height: 15),

            _SettingItem(
              icon: Icons.help_outline,
              label: "Help & Support",
              onTap: () {},
            ),

            const Spacer(),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// ------------------- REUSABLE SETTING ITEM -------------------

class _SettingItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<_SettingItem> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: hovering ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 28, color: const Color(0xffb03a57)),

                const SizedBox(width: 20),

                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2e2e2e),
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
