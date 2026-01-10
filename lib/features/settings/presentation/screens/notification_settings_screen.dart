import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.notifications),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationItem(
            context,
            icon: Icons.event,
            title: 'Appointment reminders',
            subtitle: 'Get notified before your appointments',
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            icon: Icons.notifications_active,
            title: 'Push notifications',
            subtitle: 'Enable all push notifications',
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email notifications',
            subtitle: 'Receive updates by email',
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'Important alerts',
            subtitle: 'Critical health and system alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
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
