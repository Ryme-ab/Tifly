// lib/features/reminders/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen
    final payload = response.payload;
    if (payload != null) {
      // TODO: Handle navigation based on payload
      print('Notification tapped with payload: $payload');
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tifli_reminders',
      'Baby Log Reminders',
      channelDescription: 'Notifications for baby care reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Show sleep alert
  Future<void> showSleepAlert(int hoursWithoutSleep) async {
    await showNotification(
      id: 1001,
      title: '⚠️ No Sleep Logged!',
      body: 'Your baby hasn\'t had a sleep log in $hoursWithoutSleep hours. Time to check in!',
      payload: 'sleep_alert',
    );
  }

  // Show weight reduction alert
  Future<void> showWeightAlert(double previousWeight, double currentWeight) async {
    final reduction = (previousWeight - currentWeight).toStringAsFixed(2);
    await showNotification(
      id: 1002,
      title: '⚖️ Weight Reduction Detected',
      body: 'Weight decreased by $reduction kg. Consider checking with your pediatrician.',
      payload: 'weight_alert',
    );
  }

  // Show missing logs alert
  Future<void> showMissingLogsAlert(List<String> missingLogTypes) async {
    final logsText = missingLogTypes.join(', ');
    await showNotification(
      id: 1003,
      title: '📋 Missing Daily Logs',
      body: 'You haven\'t logged: $logsText today. Don\'t forget to track!',
      payload: 'missing_logs_alert',
    );
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}