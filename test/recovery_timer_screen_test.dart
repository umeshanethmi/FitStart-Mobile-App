import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/recovery_timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'returning to active workout stops recovery and retains session progress',
    (WidgetTester tester) async {
      final session = WorkoutSession(plan: WorkoutPlan.beginnerSample)
        ..completeSet(0);

      await tester.pumpWidget(
        MaterialApp(
          home: RecoveryTimerScreen(
            session: session,
            completedExerciseIndex: 0,
          ),
        ),
      );

      await tester.tap(find.text('Start Timer'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Back to Active Workout'));
      await tester.pumpAndSettle();

      expect(find.text('Active Workout'), findsOneWidget);
      expect(find.text('SET 2'), findsOneWidget);
      expect(find.text('Back to Active Workout'), findsNothing);
      expect(
        Navigator.of(tester.element(find.text('Active Workout'))).canPop(),
        isFalse,
      );
      expect(session.completedSetsFor(0), 1);
    },
  );
}
