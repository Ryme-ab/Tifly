// lib/features/reminders/services/reminder_checker_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

enum ReminderType {
  noSleep,
  weightReduction,
  missingLogs,
}

class ReminderAlert {
  final ReminderType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isDismissed;

  ReminderAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
    this.isDismissed = false,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'is_dismissed': isDismissed,
  };

  factory ReminderAlert.fromJson(Map<String, dynamic> json) => ReminderAlert(
    type: ReminderType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    title: json['title'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    data: json['data'],
    isDismissed: json['is_dismissed'] ?? false,
  );
}

class ReminderCheckerService {
  final SupabaseClient _supabase;
  final NotificationService _notificationService;
  final String? userId;
  final String? childId;

  ReminderCheckerService({
    required SupabaseClient supabase,
    required NotificationService notificationService,
    this.userId,
    this.childId,
  })  : _supabase = supabase,
        _notificationService = notificationService;

  // Check all reminders
  Future<List<ReminderAlert>> checkAllReminders() async {
    if (userId == null || childId == null) return [];

    final alerts = <ReminderAlert>[];

    // Check sleep alert
    final sleepAlert = await _checkSleepAlert();
    if (sleepAlert != null) alerts.add(sleepAlert);

    // Check weight alert
    final weightAlert = await _checkWeightAlert();
    if (weightAlert != null) alerts.add(weightAlert);

    // Check missing logs
    final missingLogsAlert = await _checkMissingLogs();
    if (missingLogsAlert != null) alerts.add(missingLogsAlert);

    // Send notifications for new alerts
    for (var alert in alerts) {
      await _sendNotification(alert);
    }

    return alerts;
  }

  // Check for no sleep in 18 hours
  Future<ReminderAlert?> _checkSleepAlert() async {
    try {
      // Get last sleep log
      final response = await _supabase
          .from('sleep_logs')
          .select()
          .eq('user_id', userId!)
          .eq('child_id', childId!)
          .order('end_time', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      final lastSleepLog = response.first;
      final lastSleepTime = DateTime.parse(lastSleepLog['end_time']);
      final hoursSinceLastSleep = DateTime.now().difference(lastSleepTime).inHours;

      // Alert if no sleep for 18+ hours
      if (hoursSinceLastSleep >= 18) {
        return ReminderAlert(
          type: ReminderType.noSleep,
          title: '⚠️ No Sleep Logged!',
          message: 'Your baby hasn\'t had a sleep log in $hoursSinceLastSleep hours. Time to check in!',
          timestamp: DateTime.now(),
          data: {'hours_without_sleep': hoursSinceLastSleep},
        );
      }
    } catch (e) {
      print('Error checking sleep alert: $e');
    }
    return null;
  }

  // Check for weight reduction
  Future<ReminderAlert?> _checkWeightAlert() async {
    try {
      // Get last 2 weight logs
      final response = await _supabase
          .from('growth_logs')
          .select()
          .eq('user_id', userId!)
          .eq('child_id', childId!)
          .order('date', ascending: false)
          .limit(2);

      if (response.length < 2) return null;

      final currentLog = response[0];
      final previousLog = response[1];

      final currentWeight = currentLog['weight'] as double;
      final previousWeight = previousLog['weight'] as double;

      // Alert if weight decreased
      if (currentWeight < previousWeight) {
        final reduction = previousWeight - currentWeight;
        return ReminderAlert(
          type: ReminderType.weightReduction,
          title: '⚖️ Weight Reduction Detected',
          message: 'Weight decreased by ${reduction.toStringAsFixed(2)} kg. Consider checking with your pediatrician.',
          timestamp: DateTime.now(),
          data: {
            'previous_weight': previousWeight,
            'current_weight': currentWeight,
            'reduction': reduction,
          },
        );
      }
    } catch (e) {
      print('Error checking weight alert: $e');
    }
    return null;
  }

  // Check for missing critical logs today
  Future<ReminderAlert?> _checkMissingLogs() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final missingTypes = <String>[];

      // Check feeding logs
      final feedingLogs = await _supabase
          .from('feeding_logs')
          .select()
          .eq('user_id', userId!)
          .eq('child_id', childId!)
          .gte('meal_time', startOfDay.toIso8601String())
          .lt('meal_time', endOfDay.toIso8601String());

      if (feedingLogs.isEmpty) missingTypes.add('Feeding');

      // Check sleep logs
      final sleepLogs = await _supabase
          .from('sleep_logs')
          .select()
          .eq('user_id', userId!)
          .eq('child_id', childId!)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String());

      if (sleepLogs.isEmpty) missingTypes.add('Sleep');

      // Alert if any critical logs are missing (only after 6 PM)
      if (missingTypes.isNotEmpty && today.hour >= 18) {
        return ReminderAlert(
          type: ReminderType.missingLogs,
          title: '📋 Missing Daily Logs',
          message: 'You haven\'t logged: ${missingTypes.join(', ')} today. Don\'t forget to track!',
          timestamp: DateTime.now(),
          data: {'missing_logs': missingTypes},
        );
      }
    } catch (e) {
      print('Error checking missing logs: $e');
    }
    return null;
  }

  // Send notification for alert
  Future<void> _sendNotification(ReminderAlert alert) async {
    switch (alert.type) {
      case ReminderType.noSleep:
        final hours = alert.data?['hours_without_sleep'] ?? 18;
        await _notificationService.showSleepAlert(hours);
        break;
      case ReminderType.weightReduction:
        final prev = alert.data?['previous_weight'] ?? 0.0;
        final curr = alert.data?['current_weight'] ?? 0.0;
        await _notificationService.showWeightAlert(prev, curr);
        break;
      case ReminderType.missingLogs:
        final missing = (alert.data?['missing_logs'] as List?)?.cast<String>() ?? [];
        await _notificationService.showMissingLogsAlert(missing);
        break;
    }
  }

  // Save alert to database
  Future<void> saveAlert(ReminderAlert alert) async {
    try {
      await _supabase.from('reminder_alerts').insert({
        'user_id': userId,
        'child_id': childId,
        'type': alert.type.toString(),
        'title': alert.title,
        'message': alert.message,
        'data': alert.data,
        'is_dismissed': alert.isDismissed,
        'created_at': alert.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Error saving alert: $e');
    }
  }

  // Get today's active alerts
  Future<List<ReminderAlert>> getActiveAlerts() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final response = await _supabase
          .from('reminder_alerts')
          .select()
          .eq('user_id', userId!)
          .eq('child_id', childId!)
          .eq('is_dismissed', false)
          .gte('created_at', startOfDay.toIso8601String())
          .order('created_at', ascending: false);

      return response.map((json) => ReminderAlert.fromJson(json)).toList();
    } catch (e) {
      print('Error getting active alerts: $e');
      return [];
    }
  }

  // Dismiss alert
  Future<void> dismissAlert(String alertId) async {
    try {
      await _supabase
          .from('reminder_alerts')
          .update({'is_dismissed': true})
          .eq('id', alertId);
    } catch (e) {
      print('Error dismissing alert: $e');
    }
  }
}