import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/screens/reminders_screen.dart';
import 'package:fitstart_mobile_app/services/reminder_notification_service.dart';
import 'package:fitstart_mobile_app/services/notifications/notification_backend.dart';
import 'package:fitstart_mobile_app/widgets/workout_reminder_dialog.dart';

ScheduledWorkout booking(
  String id,
  DateTime date, {
  int? minutes,
  bool enabled = true,
}) {
  return ScheduledWorkout.fromMap(id, {
    'planId': 'plan',
    'title': 'Stay Fit Plan',
    'scheduledAt': Timestamp.fromDate(date),
    if (minutes != null)
      'reminder': {'minutesBefore': minutes, 'enabled': enabled},
  });
}

class FakeNotifications implements NotificationBackend {
  List<WorkoutNotification> pending = [];
  bool allowed = true;
  @override
  Future<bool> requestPermission() async => allowed;
  @override
  Future<void> replace(List<WorkoutNotification> notifications) async =>
      pending = notifications;
}

Future<void> openReminder(
  WidgetTester tester,
  Future<void> Function(int, bool) save, {
  DateTime? date,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => WorkoutReminderDialog(
                title: 'Stay Fit Plan',
                scheduledAt:
                    date ?? DateTime.now().add(const Duration(days: 1)),
                onSave: save,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  test('notifications exclude disabled, deleted and past reminders and order by reminder time', () {
    final now = DateTime(2030, 1, 1, 10);
    final notifications = ReminderNotificationService.notificationsFor([
      booking('later', now.add(const Duration(hours: 2)), minutes: 10),
      booking('first', now.add(const Duration(hours: 1)), minutes: 30),
      booking(
        'disabled',
        now.add(const Duration(hours: 1)),
        minutes: 10,
        enabled: false,
      ),
      booking('removed', now.add(const Duration(hours: 1))),
      booking('past', now.add(const Duration(minutes: 5)), minutes: 10),
    ], now);
    expect(notifications.map((n) => n.id), ['first', 'later']);
    expect(notifications.first.date, now.add(const Duration(minutes: 30)));
  });

  test(
    'reschedule replaces the notification and deletion cancels it',
    () async {
      final backend = FakeNotifications();
      final service = ReminderNotificationService(backend: backend);
      final future = DateTime.now().add(const Duration(days: 1));
      await service.synchronize([booking('workout', future, minutes: 10)]);
      expect(
        backend.pending.single.date,
        future.subtract(const Duration(minutes: 10)),
      );
      await service.synchronize([
        booking('workout', future.add(const Duration(hours: 1)), minutes: 30),
      ]);
      expect(
        backend.pending.single.date,
        future.add(const Duration(minutes: 30)),
      );
      await service.synchronize([
        booking('workout', future, minutes: 30, enabled: false),
      ]);
      expect(backend.pending, isEmpty);
      await service.synchronize([]);
      expect(backend.pending, isEmpty);
    },
  );

  test('blocked notification permission is reported', () async {
    final backend = FakeNotifications()..allowed = false;
    final service = ReminderNotificationService(backend: backend);
    await expectLater(service.requestPermission(), throwsStateError);
  });

  test(
    'too many reminders schedules the next 64 and reports the limit',
    () async {
      final backend = FakeNotifications();
      final service = ReminderNotificationService(backend: backend);
      final future = DateTime.now().add(const Duration(days: 1));
      await service.synchronize(
        List.generate(
          65,
          (index) => booking(
            '$index',
            future.add(Duration(minutes: index)),
            minutes: 0,
          ),
        ),
      );
      expect(backend.pending, hasLength(64));
      expect(backend.pending.first.id, '0');
      expect(service.error.value, isNotNull);
    },
  );

  testWidgets('lead time selection saves the chosen settings', (tester) async {
    List<Object>? saved;
    await openReminder(tester, (minutes, enabled) async {
      saved = [minutes, enabled];
    });
    await tester.tap(find.text('10 minutes before').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 minutes before').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, [30, true]);
    expect(find.byType(WorkoutReminderDialog), findsNothing);
  });

  testWidgets('past reminder is blocked but can be disabled', (tester) async {
    var saves = 0;
    bool? enabled;
    await openReminder(tester, (_, value) async {
      saves++;
      enabled = value;
    }, date: DateTime.now().add(const Duration(minutes: 5)));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(
      find.text('Choose a reminder time that is still in the future.'),
      findsOneWidget,
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(enabled, false);
  });

  testWidgets('failed save preserves settings for retry', (tester) async {
    var attempts = 0;
    await openReminder(tester, (_, _) async {
      attempts++;
      if (attempts == 1) throw StateError('Notifications are blocked.');
    });
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications are blocked.'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });

  testWidgets('save locks controls while pending', (tester) async {
    final pending = Completer<void>();
    await openReminder(tester, (_, _) => pending.future);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete();
    await tester.pumpAndSettle();
  });

  for (final size in [const Size(320, 480), const Size(1200, 800)]) {
    testWidgets('reminder and dashboard layouts fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.scrollUntilVisible(
        find.text('Reminders'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      var edits = 0;
      var deletes = 0;
      bool? toggled;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                WorkoutReminderTile(
                  workout: booking(
                    'workout',
                    DateTime.now().add(const Duration(days: 1)),
                    minutes: 10,
                  ),
                  onEdit: () => edits++,
                  onDelete: () => deletes++,
                  onToggle: (value) => toggled = value,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Edit reminder'));
      await tester.tap(find.byTooltip('Delete reminder'));
      await tester.tap(find.byType(Switch));
      expect(edits, 1);
      expect(deletes, 1);
      expect(toggled, false);
      expect(tester.takeException(), isNull);
      await openReminder(tester, (_, _) async {});
      expect(tester.takeException(), isNull);
    });
  }
}
