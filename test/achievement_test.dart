import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/achievement.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';

void main() {
  group('AchievementProgress', () {
    test('counts only unique completed workouts', () {
      final workouts = [
        _workout('done-1', DateTime(2026, 10, 1), duration: 40, calories: 500),
        _workout('done-1', DateTime(2026, 10, 1), duration: 40, calories: 500),
        _workout(
          'planned',
          DateTime(2026, 10, 2),
          status: WorkoutStatus.planned,
        ),
      ];

      final progress = AchievementProgress(workouts);

      expect(progress.completedWorkouts, hasLength(1));
      expect(progress.completedCalories, 500);
      expect(progress.completedMinutes, 40);
      expect(progress.longestWorkoutMinutes, 40);
    });

    test('counts a consecutive streak once per calendar day', () {
      final progress = AchievementProgress([
        _workout('day-1', DateTime(2026, 10, 1)),
        _workout('day-1-extra', DateTime(2026, 10, 1, 20)),
        _workout('day-2', DateTime(2026, 10, 2)),
        _workout('day-3', DateTime(2026, 10, 3)),
        _workout('day-5', DateTime(2026, 10, 5)),
      ]);

      expect(progress.longestStreakDays, 3);
      expect(
        AchievementCatalog.byId('consistency_star')!.progressFor(progress),
        1,
      );
      expect(
        AchievementCatalog.byId('weekly_warrior')!.progressFor(progress),
        closeTo(3 / 7, 0.0001),
      );
    });

    test('recognizes weekend workouts in the same calendar week only', () {
      final together = AchievementProgress([
        _workout('saturday', DateTime(2026, 10, 3)),
        _workout('sunday', DateTime(2026, 10, 4)),
      ]);
      final separateWeeks = AchievementProgress([
        _workout('saturday', DateTime(2026, 10, 3)),
        _workout('sunday', DateTime(2026, 10, 11)),
      ]);

      expect(together.weekendDays, 2);
      expect(separateWeeks.weekendDays, 1);
      expect(
        AchievementCatalog.byId('weekend_warrior')!.progressFor(together),
        1,
      );
      expect(
        AchievementCatalog.byId('weekend_warrior')!.progressFor(separateWeeks),
        0.5,
      );
    });

    test('does not infer unlocked achievements from an empty history', () {
      final progress = AchievementProgress(const []);

      expect(progress.completedWorkouts, isEmpty);
      expect(progress.completedCalories, 0);
      expect(progress.completedMinutes, 0);
      expect(progress.longestStreakDays, 0);
      expect(progress.weekendDays, 0);
      expect(
        AchievementCatalog.definitions.where(
          (definition) => definition.progressFor(progress) >= 1,
        ),
        isEmpty,
      );
    });
  });
}

WorkoutSession _workout(
  String id,
  DateTime completedAt, {
  int duration = 30,
  int calories = 250,
  WorkoutStatus status = WorkoutStatus.completed,
}) {
  return WorkoutSession(
    id: id,
    name: 'Workout $id',
    date: 'Test',
    dayIndex: completedAt.weekday - 1,
    completedAt: completedAt,
    durationMinutes: duration,
    calories: calories,
    iconCodePoint: Icons.fitness_center_rounded.codePoint,
    colorValue: const Color(0xFF2563EB).toARGB32(),
    status: status,
    exerciseSummary: const [],
  );
}
