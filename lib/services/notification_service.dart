import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Set local timezone
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Madrid')); // Adjust for Spain
    } catch (e) {
      // Fallback to UTC if timezone not found
      tz.setLocalLocation(tz.UTC);
    }

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('Notification tapped: ${response.payload}');
        }
      },
    );
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        // Request notification permission
        final granted = await androidImplementation.requestNotificationsPermission();
        
        // Request exact alarm permission for Android 13+
        final exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
        
        if (kDebugMode) {
          print('Notification permission: $granted');
          print('Exact alarm permission: $exactAlarmGranted');
        }
        
        return (granted ?? false) && (exactAlarmGranted ?? true);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mood_tracker_test',
      'Mood Tracker Test',
      channelDescription: 'Test notifications for mood tracker',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '¡Hola desde Mood Tracker!',
      'Esta es una notificación de prueba. ¡Las notificaciones funcionan correctamente!',
      platformChannelSpecifics,
      payload: 'test_notification',
    );
  }

  Future<void> showTestScheduledNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mood_tracker_test_scheduled',
      'Mood Tracker Test Scheduled',
      channelDescription: 'Test scheduled notifications for mood tracker',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    
    if (kDebugMode) {
      print('Scheduling test notification for: $scheduledDate');
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      '¡Notificación programada!',
      'Esta notificación se programó hace 10 segundos. ¡Las notificaciones programadas funcionan!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'test_scheduled_notification',
    );
  }

  Future<void> scheduleDailyMoodReminder(int hour, int minute) async {
    // Cancel any existing daily notification
    await flutterLocalNotificationsPlugin.cancel(1);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mood_tracker_daily',
      'Daily Mood Reminder',
      channelDescription: 'Daily reminders to track your mood',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    
    if (kDebugMode) {
      print('Scheduling notification for: $scheduledDate');
      print('Current time: ${tz.TZDateTime.now(tz.local)}');
    }

    // Schedule daily at the specified time
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      '¿Cómo te sientes hoy?',
      'Es hora de registrar tu estado de ánimo diario',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_mood_reminder',
    );

    // Save the notification time preference
    await _saveNotificationTime(hour, minute);
    
    if (kDebugMode) {
      print('Notification scheduled successfully');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(1);
    await _clearNotificationTime();
  }

  Future<void> _saveNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);
    await prefs.setBool('notifications_enabled', true);
  }

  Future<void> _clearNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_hour');
    await prefs.remove('notification_minute');
    await prefs.setBool('notifications_enabled', false);
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('notifications_enabled') ?? false,
      'hour': prefs.getInt('notification_hour') ?? 20,
      'minute': prefs.getInt('notification_minute') ?? 0,
    };
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> debugPendingNotifications() async {
    if (kDebugMode) {
      final pending = await getPendingNotifications();
      print('Pending notifications: ${pending.length}');
      for (final notification in pending) {
        print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }
    }
  }
}