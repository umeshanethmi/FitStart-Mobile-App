import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/training_workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/screens/daily_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/exercise_detail_screen.dart';

void main() {
  test('Saved plans and session plans remain independent', () {
    final saved = WorkoutPlan.fromMap('saved-plan', {
      'title': 'My Custom Plan',
      'exercises': [
        {'name': 'Squat', 'sets': 2, 'reps': 12, 'restSeconds': 60},
      ],
    });
    final session = WorkoutSession(plan: TrainingWorkoutPlan.beginnerSample);
    for (var set = 0; set < session.plan.exercises.first.sets; set++) {
      session.completeSet(0);
    }
    expect(session.isExerciseComplete(0), isTrue);
    expect(session.progress, 0.25);
    expect(saved.title, 'My Custom Plan');
    expect(saved.exercises.first['sets'], 2);
  });

  for (final size in [const Size(320, 640), const Size(1200, 800)]) {
    testWidgets('Merged home opens the workout flow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.scrollUntilVisible(
        find.text('Start Workout'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();
      expect(find.byType(DailyWorkoutPlanScreen), findsOneWidget);
      expect(find.text('Beginner Full-Body'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
