import 'package:flutter/material.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.settings),
      backgroundColor: AppColors.backgroundLight,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settings,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xff2e2e2e),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.managePreferences,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // Settings Items
            _SettingItem(icon: Icons.person, label: l10n.account, onTap: () {}),
            const SizedBox(height: 15),

            _SettingItem(
              icon: Icons.notifications,
              label: l10n.notifications,
              onTap: () {},
            ),
            const SizedBox(height: 15),

            _SettingItem(icon: Icons.lock, label: l10n.privacy, onTap: () {}),
            const SizedBox(height: 15),

            _SettingItem(
              icon: Icons.language_outlined,
              label: l10n.language,
              onTap: () {},
            ),
            const SizedBox(height: 15),

            _SettingItem(icon: Icons.color_lens, label: l10n.theme, onTap: () {}),
            const SizedBox(height: 15),

            _SettingItem(
              icon: Icons.help_outline,
              label: l10n.helpAndSupport,
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
