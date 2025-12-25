// lib/features/reminders/services/background_reminder_service.dart
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'reminder_checker_service.dart';

// Background task callback - MUST be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: inputData?['supabase_url'] ?? '',
        anonKey: inputData?['supabase_key'] ?? '',
      );

      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Get user and child IDs
      final userId = inputData?['user_id'] as String?;
      final childId = inputData?['child_id'] as String?;

      if (userId == null || childId == null) {
        return Future.value(true);
      }

      // Check reminders
      final reminderChecker = ReminderCheckerService(
        supabase: Supabase.instance.client,
        notificationService: notificationService,
        userId: userId,
        childId: childId,
      );

      await reminderChecker.checkAllReminders();

      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

class BackgroundReminderService {
  static const String reminderTaskName = 'baby_log_reminders';

  // Initialize background service
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  // Schedule periodic reminder checks (every 6 hours)
  static Future<void> scheduleReminderChecks({
    required String userId,
    required String childId,
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    await Workmanager().registerPeriodicTask(
      reminderTaskName,
      reminderTaskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: {
        'user_id': userId,
        'child_id': childId,
        'supabase_url': supabaseUrl,
        'supabase_key': supabaseKey,
      },
    );
  }

  // Cancel all scheduled tasks
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  // Check reminders immediately (for testing)
  static Future<void> checkNow({
    required String userId,
    required String childId,
  }) async {
    final notificationService = NotificationService();
    final reminderChecker = ReminderCheckerService(
      supabase: Supabase.instance.client,
      notificationService: notificationService,
      userId: userId,
      childId: childId,
    );

    await reminderChecker.checkAllReminders();
  }
}