import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/l10n/app_localizations.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.privacy),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
           Text(
            'Control how your data is used',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _buildToggleItem(
            context,
            icon: Icons.lock_outline,
            title: 'App lock',
            subtitle: 'Require authentication to open the app',
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            context,
            icon: Icons.visibility_off_outlined,
            title: 'Hide sensitive data',
            subtitle: 'Mask personal medical information',
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Share analytics',
            subtitle: 'Help improve the app experience',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: true, // TODO: Connect to state
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                // TODO: Implement logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
