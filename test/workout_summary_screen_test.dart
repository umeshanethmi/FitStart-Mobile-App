import 'package:fitstart_mobile_app/models/training_workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart' as progress_data;
import 'package:fitstart_mobile_app/screens/workout_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('summary displays workout stats and Done returns to dashboard', (
    WidgetTester tester,
  ) async {
    final session =
        WorkoutSession(
            plan: TrainingWorkoutPlan.beginnerSample,
            startedAt: DateTime(2026, 1, 1),
          )
          ..completeSet(0)
          ..completeSet(0)
          ..completeSet(0)
          ..skipExercise(1);
    session.completedAt = session.startedAt!.add(const Duration(minutes: 12));

    await tester.pumpWidget(
      MaterialApp(home: WorkoutSummaryScreen(session: session)),
    );

    expect(find.text('SESSION FINISHED'), findsOneWidget);
    expect(find.text('Workout finished'), findsOneWidget);
    expect(find.text('Beginner Full-Body'), findsOneWidget);
    expect(find.text('12m 0s'), findsOneWidget);
    expect(
      find.text(
        '~${progress_data.ProgressData.estimatedCaloriesForSeconds(720)} kcal',
      ),
      findsOneWidget,
    );
    expect(find.text('1 of 4 exercises'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('1 completed'), findsOneWidget);
    expect(find.text('1 skipped'), findsOneWidget);
    expect(find.text('3 sets'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Your training'), findsOneWidget);
    expect(find.text('Workout Summary'), findsNothing);
  });
}
