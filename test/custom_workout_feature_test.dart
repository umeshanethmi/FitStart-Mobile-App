import 'package:fitstart_mobile_app/features/workout/data/custom_workout_repository.dart';
import 'package:fitstart_mobile_app/features/workout/models/custom_workout.dart';
import 'package:fitstart_mobile_app/features/workout/providers/custom_workout_provider.dart';
import 'package:fitstart_mobile_app/features/workout/screens/custom_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/features/workout/screens/my_workouts_screen.dart';
import 'package:fitstart_mobile_app/features/workout/screens/workout_form_screen.dart';
import 'package:fitstart_mobile_app/models/exercise.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CustomWorkout _workout({String id = '', String name = 'Test workout'}) =>
    CustomWorkout(
      id: id,
      name: name,
      level: 'Beginner',
      exercises: const [
        Exercise(
          name: 'Test squat',
          description: 'Test instructions.',
          sets: 3,
          reps: 10,
          restSeconds: 30,
          targetArea: 'Legs',
          beginnerTip: 'Keep your chest lifted.',
        ),
      ],
    );

void main() {
  group('CustomWorkoutRepository', () {
    test('seeds from the existing beginner workout', () async {
      final repository = CustomWorkoutRepository();
      final workouts = await repository.getAll();

      expect(workouts, hasLength(1));
      expect(workouts.single.id, 'beginner-full-body');
      expect(workouts.single.name, 'Beginner Full-Body');
      expect(workouts.single.exercises, hasLength(4));
      expect(workouts.single.toWorkoutPlan().durationMinutes, 20);
      expect(
        workouts.single.toWorkoutPlan().exercises.first.description,
        WorkoutPlan.beginnerSample.exercises.first.description,
      );
    });

    test('supports create, get, update, delete, and restore', () async {
      final repository = CustomWorkoutRepository(initialWorkouts: []);

      final created = await repository.create(_workout());
      expect(created.id, isNotEmpty);
      expect(await repository.getById(created.id), created);
      expect(await repository.getAll(), [created]);

      final updated = _workout(id: created.id, name: 'Updated workout');
      await repository.update(updated);
      expect((await repository.getById(created.id))?.name, 'Updated workout');

      final deleted = await repository.delete(created.id);
      expect(await repository.getById(created.id), isNull);
      expect(await repository.getAll(), isEmpty);

      await repository.restore(deleted);
      expect(await repository.getAll(), [updated]);
    });
  });

  testWidgets('My Workouts shows the seeded workout without narrow overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MyWorkoutsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Workouts'), findsOneWidget);
    expect(find.text('Beginner Full-Body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete confirmation offers Undo and restores the workout', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MyWorkoutsScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete Beginner Full-Body'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Beginner Full-Body deleted'), findsOneWidget);
    expect(find.text('No workouts yet'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Beginner Full-Body'), findsOneWidget);
  });

  testWidgets('My Workouts displays its empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customWorkoutRepositoryProvider.overrideWithValue(
            CustomWorkoutRepository(initialWorkouts: []),
          ),
        ],
        child: const MaterialApp(home: MyWorkoutsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No workouts yet'), findsOneWidget);
    expect(find.text('Create workout'), findsOneWidget);
  });

  testWidgets('workout form supports adding an exercise and validates name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WorkoutFormScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Workout name is required.'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Exercise 2'), findsOneWidget);
  });

  testWidgets('selected workout is passed into the existing plan screen', (
    tester,
  ) async {
    final selected = _workout(id: 'selected', name: 'Selected Workout');
    final repository = CustomWorkoutRepository(initialWorkouts: [selected]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customWorkoutRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: CustomWorkoutPlanScreen(workoutId: 'selected'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selected Workout'), findsOneWidget);
    expect(find.text('Test squat'), findsOneWidget);
  });
}
