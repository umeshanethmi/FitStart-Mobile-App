import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/screens/ai_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/widgets/edit_plan_exercise_dialog.dart';

const exercise = {
  'exerciseId': 'bodyweight_squat',
  'name': 'Bodyweight squat',
  'sets': 2,
  'reps': 12,
  'restSeconds': 60,
};

Future<void> openEditor(
  WidgetTester tester,
  Future<void> Function(int, int, int) onSave,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) =>
                  EditPlanExerciseDialog(exercise: exercise, onSave: onSave),
            ),
            child: const Text('Edit'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
}

void main() {
  test('legacy documents retain ID and derive an exercise name', () {
    final plan = WorkoutPlan.fromMap('original-id', {
      'title': 'Starter Plan',
      'exercises': [
        {'exerciseId': 'bench_press', 'sets': 4, 'reps': 8, 'restSeconds': 90},
      ],
    });
    expect(plan.id, 'original-id');
    expect(plan.preferences, isEmpty);
    expect(WorkoutPlan.exerciseName(plan.exercises.single), 'bench press');
  });

  for (final size in [const Size(320, 640), const Size(1200, 800)]) {
    testWidgets('plan and edit controls fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var editedIndex = -1;
      var deleteRequests = 0;
      var scheduleRequests = 0;
      final plan = WorkoutPlan.fromMap('plan', {
        'title': 'Build Muscle Plan',
        'preferences': {
          'goal': 'Build Muscle',
          'experience': 'Beginner',
          'equipment': 'None',
          'daysPerWeek': 3,
          'durationMinutes': 30,
        },
        'exercises': [exercise],
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                WorkoutPlanDetails(
                  plan: plan,
                  onEdit: (index) => editedIndex = index,
                  onDelete: () => deleteRequests++,
                  onSchedule: () => scheduleRequests++,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Edit exercise'));
      expect(editedIndex, 0);
      await tester.tap(find.byTooltip('Delete plan'));
      expect(deleteRequests, 1);
      await tester.tap(find.text('Schedule Workout'));
      expect(scheduleRequests, 1);
      expect(tester.takeException(), isNull);
      await openEditor(tester, (_, _, _) async {});
      expect(find.text('Bodyweight squat'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invalid values block saving', (tester) async {
    var saves = 0;
    await openEditor(tester, (_, _, _) async {
      saves++;
    });
    await tester.enterText(find.byType(TextFormField).at(0), '0');
    await tester.enterText(find.byType(TextFormField).at(1), '201');
    await tester.enterText(find.byType(TextFormField).at(2), '601');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Enter a number from 1 to 10.'), findsOneWidget);
    expect(find.text('Enter a number from 1 to 200.'), findsOneWidget);
    expect(find.text('Enter a number from 0 to 600.'), findsOneWidget);
  });

  testWidgets('valid edits save values and close the dialog', (tester) async {
    List<int>? saved;
    await openEditor(tester, (sets, reps, rest) async {
      saved = [sets, reps, rest];
    });
    await tester.enterText(find.byType(TextFormField).at(0), '3');
    await tester.enterText(find.byType(TextFormField).at(1), '15');
    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, [3, 15, 0]);
    expect(find.byType(EditPlanExerciseDialog), findsNothing);
  });

  testWidgets('failed save preserves edits and allows retry', (tester) async {
    var attempts = 0;
    await openEditor(tester, (_, _, _) async {
      attempts++;
      if (attempts == 1) throw Exception('offline');
    });
    await tester.enterText(find.byType(TextFormField).first, '4');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save changes. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(EditPlanExerciseDialog), findsNothing);
  });

  testWidgets('pending save disables commands and duplicate submissions', (
    tester,
  ) async {
    final pending = Completer<void>();
    var saves = 0;
    await openEditor(tester, (_, _, _) {
      saves++;
      return pending.future;
    });
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saves, 1);
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
    expect(find.byType(EditPlanExerciseDialog), findsNothing);
  });
}
