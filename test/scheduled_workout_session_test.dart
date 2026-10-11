import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/scheduled_workout.dart';
import 'package:fitstart_mobile_app/models/training_workout_plan.dart';
import 'package:fitstart_mobile_app/screens/daily_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_summary_screen.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';

ScheduledWorkout booking(
  String id,
  String title,
  List<Map<String, dynamic>> exercises, {
  Map<String, dynamic>? preferences,
}) => ScheduledWorkout.fromMap(id, {
  'planId': 'plan-$id',
  'title': title,
  'scheduledAt': Timestamp.fromDate(DateTime(2027, 1, 12, 8, 30)),
  'exercises': exercises,
  'preferences': preferences ?? {},
});

const strengthExercises = [
  {'name': 'Seated cable row', 'sets': 2, 'reps': 6, 'restSeconds': 30},
  {'name': 'Dead bug', 'sets': 1, 'reps': 12, 'restSeconds': 0},
];

void main() {
  test(
    'Schedule conversion preserves the ordered snapshot and preferences',
    () {
      final workout = booking(
        'strength',
        'Lunch Strength',
        strengthExercises,
        preferences: {'experience': 'Advanced', 'durationMinutes': 45},
      );
      final plan = TrainingWorkoutPlan.fromScheduledWorkout(workout);
      expect(plan.name, 'Lunch Strength');
      expect(plan.difficulty, 'Advanced');
      expect(plan.durationMinutes, 45);
      expect(plan.durationIsEstimate, false);
      expect(plan.exercises.map((exercise) => exercise.name), [
        'Seated cable row',
        'Dead bug',
      ]);
      expect(plan.exercises.first.sets, 2);
      expect(plan.exercises.first.reps, 6);
      expect(plan.exercises.first.restSeconds, 30);
      expect(plan.exercises.first.description, contains('6 repetitions'));
    },
  );

  test('Legacy schedules and timed exercises do not use sample exercises', () {
    final plan = TrainingWorkoutPlan.fromScheduledWorkout(
      booking('legacy', 'Core', [
        {
          'exerciseId': 'standing_march',
          'sets': 3,
          'durationSeconds': 20,
          'restSeconds': 10,
          'description': 'Saved instructions',
          'targetArea': 'Core',
          'beginnerTip': 'Saved tip',
        },
      ]),
    );
    expect(plan.exercises.single.name, 'standing march');
    expect(plan.exercises.single.reps, isNull);
    expect(plan.exercises.single.durationSeconds, 20);
    expect(plan.exercises.single.description, 'Saved instructions');
    expect(plan.exercises.single.targetArea, 'Core');
    expect(plan.exercises.single.beginnerTip, 'Saved tip');
    expect(plan.difficulty, 'Scheduled workout');
    expect(plan.durationIsEstimate, true);
    expect(plan.durationMinutes, 2);
  });

  test('Empty or malformed snapshots cannot start an inaccurate session', () {
    for (final exercises in <List<Map<String, dynamic>>>[
      [],
      [
        {'name': 'Squat', 'sets': 0, 'reps': 10, 'restSeconds': 30},
      ],
      [
        {'name': 'Squat', 'sets': 2, 'reps': null, 'restSeconds': 30},
      ],
      [
        {'name': 'Squat', 'sets': 2.5, 'reps': 10, 'restSeconds': 30},
      ],
    ]) {
      expect(
        () => TrainingWorkoutPlan.fromScheduledWorkout(
          booking('invalid', 'Invalid', exercises),
        ),
        throwsFormatException,
      );
    }
  });

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1200, 800),
  ]) {
    testWidgets(
      'Selected schedule completes its own sets and exercise sequence at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final strength = booking(
          'strength',
          'Lunch Strength',
          strengthExercises,
        );
        final other = booking('other', 'Other Routine', [
          {'name': 'Calf raise', 'sets': 4, 'reps': 8, 'restSeconds': 60},
        ]);
        var savedWorkoutCount = 0;
        Map<String, dynamic>? savedRecord;
        final completionGate = Completer<String?>();
        await tester.pumpWidget(
          MaterialApp(
            home: WorkoutPage(
              title: 'Workout Schedule',
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final workout in [strength, other])
                    ScheduledWorkoutDetails(
                      key: ValueKey(workout.id),
                      workout: workout,
                      onReschedule: () {},
                      onDelete: () {},
                      onReminder: () {},
                      onWorkoutCompleted: (session) async {
                        savedWorkoutCount++;
                        savedRecord = session.toProgressRecord();
                        return completionGate.future;
                      },
                    ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Start Workout'), findsNWidgets(2));
        final start = find.descendant(
          of: find.byKey(const ValueKey('strength')),
          matching: find.text('Start Workout'),
        );
        await tester.tap(start);
        await tester.pumpAndSettle();
        final daily = tester.widget<DailyWorkoutPlanScreen>(
          find.byType(DailyWorkoutPlanScreen),
        );
        expect(daily.plan.name, 'Lunch Strength');
        expect(find.text('Seated cable row'), findsOneWidget);
        expect(daily.plan.exercises.last.name, 'Dead bug');
        expect(find.text('Calf raise'), findsNothing);
        expect(find.text('Wall Push-Up'), findsNothing);
        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('2 sets \u00b7 6 reps'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('2 sets \u00b7 6 reps'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('30 seconds'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('30 seconds'), findsOneWidget);
        await tester.tap(find.text('Start Exercise'));
        await tester.pumpAndSettle();
        expect(find.text('6 repetitions'), findsOneWidget);
        expect(find.text('SET 1'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        Future<void> tapStep(String label) async {
          await tester.scrollUntilVisible(
            find.text(label),
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await tapStep('Complete Set');
        expect(find.text('00:30'), findsOneWidget);
        await tapStep('Skip Recovery');
        expect(find.text('Seated cable row'), findsOneWidget);
        expect(find.text('SET 2'), findsOneWidget);
        await tapStep('Finish Exercise');
        await tapStep('Skip Recovery');
        expect(find.text('Dead bug'), findsOneWidget);
        await tester.tap(find.text('Start Exercise'));
        await tester.pumpAndSettle();
        expect(find.text('12 repetitions'), findsOneWidget);
        await tapStep('Finish Exercise');
        expect(find.text('00:00'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('View Workout Summary'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('View Workout Summary'));
        await tester.pump();
        expect(find.text('Saving workout...'), findsOneWidget);
        await tester.tap(find.text('Saving workout...'));
        await tester.pump();
        completionGate.complete(null);
        await tester.pumpAndSettle();
        final summary = tester.widget<WorkoutSummaryScreen>(
          find.byType(WorkoutSummaryScreen),
        );
        expect(summary.session.completedSetCount, 3);
        expect(summary.session.completedExerciseCount, 2);
        expect(summary.session.plan.name, 'Lunch Strength');
        expect(summary.session.completedAt, isNotNull);
        expect(summary.progressSaved, isTrue);
        expect(summary.completionWarning, isNull);
        expect(savedWorkoutCount, 1);
        expect(savedRecord?['durationSeconds'], greaterThan(0));
        expect(savedRecord?['durationMinutes'], greaterThanOrEqualTo(1));
        expect(savedRecord?['calories'], greaterThan(0));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Start is disabled for empty schedules and invalid sets show an error',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WorkoutPage(
            title: 'Workout Schedule',
            body: ListView(
              children: [
                ScheduledWorkoutDetails(
                  workout: booking('empty', 'Empty', []),
                  onReschedule: () {},
                  onDelete: () {},
                  onReminder: () {},
                ),
                ScheduledWorkoutDetails(
                  workout: booking('invalid', 'Invalid', [
                    {
                      'name': 'Squat',
                      'sets': -1,
                      'reps': 10,
                      'restSeconds': 30,
                    },
                  ]),
                  onReschedule: () {},
                  onDelete: () {},
                  onReminder: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );
      await tester.tap(find.text('Start Workout').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Invalid Squat: sets. Update the workout before starting.'),
        findsOneWidget,
      );
      expect(find.byType(DailyWorkoutPlanScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
