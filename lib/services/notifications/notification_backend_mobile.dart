import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_backend.dart';

NotificationBackend createNotificationBackend() => MobileNotificationBackend();

class MobileNotificationBackend implements NotificationBackend {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;

  bool get _supported => [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);

  Future<void> _initialize() => _initialization ??= _setup();

  Future<void> _setup() async {
    if (!_supported) return;
    tz_data.initializeTimeZones();
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: darwin,
        macOS: darwin,
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!_supported) {
      throw StateError(
        'Notifications are supported on Android, iOS, macOS, and Chrome.',
      );
    }
    await _initialize();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, sound: true, badge: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, sound: true, badge: true) ??
            false;
      default:
        return false;
    }
  }

  @override
  Future<void> replace(List<WorkoutNotification> notifications) async {
    if (!_supported) {
      if (notifications.isNotEmpty) {
        throw StateError(
          'Notifications are supported on Android, iOS, macOS, and Chrome.',
        );
      }
      return;
    }
    await _initialize();
    await _plugin.cancelAll();
    if (notifications.isNotEmpty) {
      final bool allowed;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          allowed =
              await _plugin
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.areNotificationsEnabled() ??
              false;
        case TargetPlatform.iOS:
          allowed =
              (await _plugin
                      .resolvePlatformSpecificImplementation<
                        IOSFlutterLocalNotificationsPlugin
                      >()
                      ?.checkPermissions())
                  ?.isEnabled ??
              false;
        case TargetPlatform.macOS:
          allowed =
              (await _plugin
                      .resolvePlatformSpecificImplementation<
                        MacOSFlutterLocalNotificationsPlugin
                      >()
                      ?.checkPermissions())
                  ?.isEnabled ??
              false;
        default:
          allowed = false;
      }
      if (!allowed) {
        throw StateError(
          'Allow notifications on this device to receive your reminders.',
        );
      }
    }
    for (var index = 0; index < notifications.length; index++) {
      final notification = notifications[index];
      if (!notification.date.isAfter(DateTime.now())) continue;
      await _plugin.zonedSchedule(
        index + 1,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.date, tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminders',
            'Workout Reminders',
            channelDescription: 'Upcoming scheduled workouts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notification.id,
      );
    }
  }
}
