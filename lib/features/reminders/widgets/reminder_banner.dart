// lib/features/reminders/widgets/reminder_banner.dart
import 'package:flutter/material.dart';
import '../services/reminder_checker_service.dart';

class ReminderBanner extends StatelessWidget {
  final ReminderAlert alert;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const ReminderBanner({
    Key? key,
    required this.alert,
    required this.onDismiss,
    required this.onTap,
  }) : super(key: key);

  Color _getAlertColor() {
    switch (alert.type) {
      case ReminderType.noSleep:
        return const Color(0xFF7E57C2); // Purple
      case ReminderType.weightReduction:
        return const Color(0xFFE74C3C); // Red
      case ReminderType.missingLogs:
        return const Color(0xFF6B6BFF); // Blue
    }
  }

  IconData _getAlertIcon() {
    switch (alert.type) {
      case ReminderType.noSleep:
        return Icons.bedtime_outlined;
      case ReminderType.weightReduction:
        return Icons.monitor_weight_outlined;
      case ReminderType.missingLogs:
        return Icons.edit_note_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAlertColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getAlertIcon(),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Dismiss button
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDismiss,
              color: Colors.black54,
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to show all active reminders
class ReminderBannerList extends StatelessWidget {
  final List<ReminderAlert> alerts;
  final Function(ReminderAlert) onDismiss;
  final Function(ReminderAlert) onTap;

  const ReminderBannerList({
    Key? key,
    required this.alerts,
    required this.onDismiss,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alert) {
        return ReminderBanner(
          alert: alert,
          onDismiss: () => onDismiss(alert),
          onTap: () => onTap(alert),
        );
      }).toList(),
    );
  }
}