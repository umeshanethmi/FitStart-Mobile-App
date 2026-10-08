import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';

void main() {
  group('ProgressMetrics', () {
    test('derives weekly totals from completed workouts', () {
      final metrics = ProgressMetrics(ProgressData.sampleWorkouts);

      expect(metrics.completedCount, 4);
      expect(metrics.totalDurationMinutes, 205);
      expect(metrics.totalCalories, 1840);
      expect(metrics.dailyActiveMinutes, [0, 67, 0, 30, 0, 48, 60]);
    });

    test('updates progress totals when workout status changes', () {
      final workouts = ProgressData.sampleWorkouts
          .map(
            (workout) => workout.id == 'recovery_walk'
                ? workout.copyWith(status: WorkoutStatus.completed)
                : workout,
          )
          .toList();
      final metrics = ProgressMetrics(workouts);

      expect(metrics.completedCount, 5);
      expect(metrics.workoutCompletionPercent, 100);
    });

    test('returns zeroed metrics when no workout records exist', () {
      final metrics = ProgressMetrics(const []);

      expect(metrics.completedCount, 0);
      expect(metrics.totalWorkoutCount, 0);
      expect(metrics.totalDurationMinutes, 0);
      expect(metrics.totalCalories, 0);
      expect(metrics.dailyActiveMinutes, List<int>.filled(7, 0));
    });
  });

  group('WorkoutSession persistence mapping', () {
    test('round-trips workout and exercise fields', () {
      final original = ProgressData.sampleWorkouts.first.copyWith(
        notes: 'Felt strong.',
        rating: 5,
      );

      final restored = WorkoutSession.fromMap(original.id, original.toMap());

      expect(restored.name, original.name);
      expect(restored.status, WorkoutStatus.completed);
      expect(restored.notes, 'Felt strong.');
      expect(restored.rating, 5);
      expect(restored.exerciseSummary.length, 4);
      expect(restored.exerciseSummary.first.name, 'Squats');
      expect(restored.exerciseSummary.first.isCompleted, isTrue);
      expect(restored.weekStart, original.weekStart);
      expect(restored.completedAt, original.completedAt);
    });

    test('reads legacy generated workout plan documents safely', () {
      final workout = WorkoutSession.fromMap('starter_plan', {
        'userId': 'signed-in-user',
        'title': 'Stay Fit Starter Plan',
        'isActive': true,
        'createdAt': DateTime(2026, 10, 6),
        'exercises': [
          {'exerciseId': 'jump_rope', 'sets': 3, 'reps': 50, 'restSeconds': 30},
          {'exerciseId': 'plank', 'sets': '3', 'reps': 1, 'restSeconds': 60},
        ],
      });

      expect(workout.name, 'Stay Fit Starter Plan');
      expect(workout.status, WorkoutStatus.planned);
      expect(workout.exerciseSummary.first.id, 'jump_rope');
      expect(workout.exerciseSummary.first.name, 'Jump Rope');
      expect(workout.exerciseSummary.first.sets, 3);
      expect(workout.exerciseSummary.last.sets, 3);
    });

    test('handles empty and malformed optional fields without throwing', () {
      final workout = WorkoutSession.fromMap('minimal_plan', {
        'title': 12,
        'status': 42,
        'exercises': 'not-a-list',
        'durationMinutes': 'unknown',
        'rating': null,
      });

      expect(workout.name, 'Workout');
      expect(workout.status, WorkoutStatus.planned);
      expect(workout.exerciseSummary, isEmpty);
      expect(workout.durationMinutes, 0);
      expect(workout.rating, 0);
    });
  });
}
