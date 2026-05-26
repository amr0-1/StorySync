import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Completely decoupled notification service — no UI widget dependencies.
///
/// Manages local notification initialization and display for StorySync.
/// Uses the "StorySync Streaks" Android channel for streak reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Android notification channel for streak reminders.
  static const String _channelId = 'storysync_streaks';
  static const String _channelName = 'StorySync Streaks';
  static const String _channelDescription =
      'Reminders to keep your reading streak alive';

  /// Notification IDs
  static const int streakReminderId = 1001;

  /// Initialize the notification plugin.
  ///
  /// Must be called once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the notification channel (Android 8.0+)
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;
  }

  /// Show a streak reminder notification.
  Future<void> showStreakReminder({
    String title = 'Your streak is at risk! 📖',
    String body = 'You haven\'t read anything today. Open StorySync to keep your streak alive!',
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      streakReminderId,
      title,
      body,
      details,
    );
  }

  /// Cancel the streak reminder notification.
  Future<void> cancelStreakReminder() async {
    await _plugin.cancel(streakReminderId);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Callback when user taps a notification.
  static void _onNotificationTap(NotificationResponse response) {
    // The app will be brought to the foreground automatically.
    // No deep-link routing needed for streak reminders.
  }
}
