import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/exercise.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/active_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'completed exercise offers Next Workout and prevents duplicate completion',
    (WidgetTester tester) async {
      const plan = WorkoutPlan(
        name: 'Next workout test',
        durationMinutes: 10,
        difficulty: 'Beginner',
        exercises: [
          Exercise(
            name: 'Completed Exercise',
            description: 'Test description',
            targetArea: 'Test area',
            sets: 3,
            reps: 10,
            restSeconds: 30,
            beginnerTip: 'Test tip',
          ),
          Exercise(
            name: 'Next Exercise',
            description: 'Test description',
            targetArea: 'Test area',
            sets: 3,
            reps: 10,
            restSeconds: 30,
            beginnerTip: 'Test tip',
          ),
        ],
      );
      final session = WorkoutSession(plan: plan)
        ..completeSet(0)
        ..completeSet(0)
        ..completeSet(0);

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveWorkoutScreen(session: session, exerciseIndex: 0),
        ),
      );

      expect(find.text('Next Workout'), findsOneWidget);
      expect(find.text('Skip Workout'), findsNothing);
      final finishExercise = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Finish Exercise'),
      );
      expect(finishExercise.onPressed, isNull);

      await tester.tap(find.text('Next Workout'));
      await tester.pumpAndSettle();

      expect(find.text('Exercise Details'), findsOneWidget);
      expect(find.text('Next Exercise'), findsOneWidget);
      expect(session.completedSetsFor(0), 3);
      expect(session.completedExerciseCount, 1);
      expect(session.skippedExerciseCount, 0);
    },
  );

  testWidgets(
    'skipping an exercise advances and retains partial set progress',
    (WidgetTester tester) async {
      const plan = WorkoutPlan(
        name: 'Skip test',
        durationMinutes: 10,
        difficulty: 'Beginner',
        exercises: [
          Exercise(
            name: 'Test Exercise One',
            description: 'Test description',
            targetArea: 'Test area',
            sets: 3,
            reps: 10,
            restSeconds: 30,
            beginnerTip: 'Test tip',
          ),
          Exercise(
            name: 'Test Exercise Two',
            description: 'Test description',
            targetArea: 'Test area',
            sets: 3,
            reps: 10,
            restSeconds: 30,
            beginnerTip: 'Test tip',
          ),
        ],
      );
      final session = WorkoutSession(plan: plan)..completeSet(0);

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveWorkoutScreen(session: session, exerciseIndex: 0),
        ),
      );

      await tester.tap(find.text('Skip Workout'));
      await tester.pumpAndSettle();

      expect(find.text('Exercise Details'), findsOneWidget);
      expect(find.text('Test Exercise Two'), findsOneWidget);
      expect(session.completedSetsFor(0), 1);
      expect(session.completedExerciseCount, 0);
      expect(session.skippedExerciseCount, 1);
    },
  );

  testWidgets(
    'skipping the last exercise preserves progress and reports counts',
    (WidgetTester tester) async {
      final session = WorkoutSession(plan: WorkoutPlan.beginnerSample)
        ..completeSet(0)
        ..completeSet(0)
        ..completeSet(0)
        ..completeSet(3);

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveWorkoutScreen(session: session, exerciseIndex: 3),
        ),
      );

      await tester.tap(find.text('Skip Workout'));
      await tester.pumpAndSettle();

      expect(find.text('Workout Summary'), findsOneWidget);
      expect(find.text('1 of 4 exercises'), findsOneWidget);
      expect(find.text('1 completed'), findsOneWidget);
      expect(find.text('1 skipped'), findsOneWidget);
      expect(find.text('4 sets'), findsOneWidget);
      expect(session.completedExerciseCount, 1);
      expect(session.skippedExerciseCount, 1);
      expect(session.completedSetCount, 4);

      session.skipExercise(3);
      session.completeSet(3);
      expect(session.skippedExerciseCount, 1);
      expect(session.completedSetCount, 4);
    },
  );
}
