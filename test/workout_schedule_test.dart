import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/widgets/delete_workout_plan_dialog.dart';
import 'package:fitstart_mobile_app/widgets/schedule_workout_dialog.dart';

Future<void> openScheduler(
  WidgetTester tester,
  Future<void> Function(DateTime) save, {
  DateTime? initialDate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => ScheduleWorkoutDialog(
                title: 'Stay Fit Plan',
                initialDate: initialDate,
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
  test('schedule restores local time, plan reference and exercises', () {
    final date = DateTime(2030, 4, 10, 9, 30);
    final workout = ScheduledWorkout.fromMap('booking', {
      'planId': 'plan',
      'title': 'Stay Fit Plan',
      'scheduledAt': Timestamp.fromDate(date),
      'exercises': [
        {'exerciseId': 'squat', 'sets': 2, 'reps': 12, 'restSeconds': 60},
      ],
    });
    expect(workout.id, 'booking');
    expect(workout.planId, 'plan');
    expect(workout.scheduledAt, date);
    expect(workout.exercises.single['exerciseId'], 'squat');
  });

  testWidgets('date and time pickers open and future booking saves', (
    tester,
  ) async {
    DateTime? saved;
    await openScheduler(tester, (date) async => saved = date);
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.schedule));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved!.isAfter(DateTime.now()), isTrue);
    expect(saved!.second, 0);
    expect(find.byType(ScheduleWorkoutDialog), findsNothing);
  });

  testWidgets('past booking cannot be saved', (tester) async {
    var saves = 0;
    await openScheduler(tester, (_) async {
      saves++;
    }, initialDate: DateTime.now().subtract(const Duration(days: 1)));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Choose a future date and time.'), findsOneWidget);
  });

  testWidgets('rescheduling preserves selected date and time', (tester) async {
    final date = DateTime.now().add(const Duration(days: 3));
    DateTime? saved;
    await openScheduler(
      tester,
      (value) async => saved = value,
      initialDate: date,
    );
    expect(find.text('Reschedule Workout'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      saved,
      DateTime(date.year, date.month, date.day, date.hour, date.minute),
    );
  });

  testWidgets('cancel does not save', (tester) async {
    var saves = 0;
    await openScheduler(tester, (_) async {
      saves++;
    });
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.byType(ScheduleWorkoutDialog), findsNothing);
  });

  testWidgets('failed save permits retry', (tester) async {
    var attempts = 0;
    await openScheduler(tester, (_) async {
      attempts++;
      if (attempts == 1) {
        throw StateError('This workout plan is no longer available.');
      }
    });
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('This workout plan is no longer available.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(ScheduleWorkoutDialog), findsNothing);
  });

  testWidgets('Firebase permission failure shows the cause', (tester) async {
    await openScheduler(tester, (_) async {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
    });
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Firebase denied permission to save this workout. Your account needs access to workout schedules.',
      ),
      findsOneWidget,
    );
    expect(find.byType(ScheduleWorkoutDialog), findsOneWidget);
  });

  testWidgets('pending save disables further submissions', (tester) async {
    final pending = Completer<void>();
    await openScheduler(tester, (_) => pending.future);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    pending.complete();
    await tester.pumpAndSettle();
  });

  for (final size in [const Size(320, 640), const Size(1200, 800)]) {
    testWidgets('schedule controls fit $size and call correct actions', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var reschedules = 0;
      var deletions = 0;
      final workout = ScheduledWorkout.fromMap('booking', {
        'planId': 'plan',
        'title': 'Build Muscle Plan',
        'scheduledAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 1)),
        ),
        'exercises': [
          {
            'name': 'Dumbbell floor press',
            'sets': 3,
            'reps': 8,
            'restSeconds': 90,
          },
        ],
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ScheduledWorkoutDetails(
                  workout: workout,
                  onReschedule: () => reschedules++,
                  onDelete: () => deletions++,
                  onReminder: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Build Muscle Plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Reschedule workout'));
      await tester.tap(find.byTooltip('Delete scheduled workout'));
      expect(reschedules, 1);
      expect(deletions, 1);
      expect(find.text('Dumbbell floor press'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await openScheduler(tester, (_) async {});
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('scheduled deletion confirmation describes keeping the plan', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeleteWorkoutPlanDialog(
          title: 'Stay Fit Plan',
          scheduledWorkout: true,
          onDelete: () async {},
        ),
      ),
    );
    expect(find.text('Delete scheduled workout?'), findsOneWidget);
    expect(
      find.text(
        'Remove "Stay Fit Plan" from your schedule? Your saved plan will be kept.',
      ),
      findsOneWidget,
    );
  });
}
