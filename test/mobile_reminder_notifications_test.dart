import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fitstart_mobile_app/services/notifications/notification_backend.dart';
import 'package:fitstart_mobile_app/services/notifications/notification_backend_mobile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  var allowed = true;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    allowed = true;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'initialize') return true;
          if (call.method == 'areNotificationsEnabled' ||
              call.method == 'requestNotificationsPermission') {
            return allowed;
          }
          return null;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'Android schedules future notifications with the workout payload',
    () async {
      final backend = MobileNotificationBackend();
      expect(await backend.requestPermission(), isTrue);
      await backend.replace([
        WorkoutNotification(
          id: 'booking',
          title: 'Workout',
          date: DateTime.now().add(const Duration(hours: 1)),
          body: 'Starting soon',
        ),
      ]);
      expect(calls.where((call) => call.method == 'cancelAll'), hasLength(1));
      final schedule = calls.singleWhere(
        (call) => call.method == 'zonedSchedule',
      );
      final arguments = schedule.arguments as Map;
      expect(arguments['payload'], 'booking');
      expect(arguments['title'], 'Workout');
    },
  );

  test(
    'revoked permission cancels pending alerts and reports failure',
    () async {
      allowed = false;
      final backend = MobileNotificationBackend();
      await expectLater(
        backend.replace([
          WorkoutNotification(
            id: 'booking',
            title: 'Workout',
            date: DateTime.now().add(const Duration(hours: 1)),
            body: 'Starting soon',
          ),
        ]),
        throwsStateError,
      );
      expect(calls.any((call) => call.method == 'cancelAll'), isTrue);
      expect(calls.any((call) => call.method == 'zonedSchedule'), isFalse);
    },
  );

  test(
    'empty reminder list cancels pending notifications without prompting',
    () async {
      final backend = MobileNotificationBackend();
      await backend.replace([]);
      expect(calls.any((call) => call.method == 'cancelAll'), isTrue);
      expect(
        calls.any((call) => call.method == 'requestNotificationsPermission'),
        isFalse,
      );
    },
  );
}
