import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/models/achievement.dart';
import 'package:fitstart_mobile_app/models/exercise.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/models/training_workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart' as active;

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
      expect(metrics.previousWeekActiveMinutes, 0);
      expect(metrics.hasPreviousWeekData, isFalse);
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

  test('completed active session maps to progress and achievement data', () {
    final session = active.WorkoutSession(
      plan: const TrainingWorkoutPlan(
        name: 'Test strength session',
        durationMinutes: 30,
        difficulty: 'Beginner',
        exercises: [
          Exercise(
            name: 'Squat',
            description: 'Squat',
            targetArea: 'Legs',
            sets: 1,
            reps: 8,
            restSeconds: 0,
            beginnerTip: '',
          ),
        ],
      ),
    );
    session.start(at: DateTime.now().subtract(const Duration(minutes: 30)));
    session.completeSet(0);
    session.finish();

    final record = WorkoutSession.fromMap(
      'completion-record',
      session.toProgressRecord(),
    );
    final metrics = ProgressMetrics([record]);
    final achievements = AchievementProgress([record]);

    expect(record.status, WorkoutStatus.completed);
    expect(record.name, 'Test strength session');
    expect(record.exerciseSummary.single.isCompleted, isTrue);
    expect(metrics.completedCount, 1);
    expect(metrics.totalDurationMinutes, session.elapsed.inMinutes);
    expect(
      metrics.totalCalories,
      session.elapsed.inMinutes * ProgressData.estimatedCaloriesPerMinute,
    );
    expect(achievements.completedWorkouts, hasLength(1));
  });

  test(
    'active duration starts on exercise start and retains short seconds',
    () {
      final start = DateTime(2026, 10, 9, 10);
      final session = active.WorkoutSession(
        plan: const TrainingWorkoutPlan(
          name: 'Short session',
          durationMinutes: 20,
          difficulty: 'Beginner',
          exercises: [
            Exercise(
              name: 'March',
              description: 'March in place',
              targetArea: 'Legs',
              sets: 1,
              reps: 10,
              restSeconds: 0,
              beginnerTip: '',
            ),
          ],
        ),
      );

      expect(session.startedAt, isNull);
      expect(session.elapsed, Duration.zero);
      session.start(at: start);
      session.start(at: start.subtract(const Duration(minutes: 20)));
      session.completeSet(0);
      session.finish(at: start.add(const Duration(seconds: 45)));

      final record = session.toProgressRecord();
      expect(session.startedAt, start);
      expect(session.elapsed, const Duration(seconds: 45));
      expect(record['durationSeconds'], 45);
      expect(record['durationMinutes'], 1);
      expect(record['calories'], 5);
      expect(
        ProgressData.durationLabel(record['durationSeconds'] as int),
        '45 sec',
      );
      expect(ProgressData.estimatedCaloriesForSeconds(0), 0);
      expect(
        ProgressData.estimatedCaloriesForSeconds(60),
        ProgressData.estimatedCaloriesPerMinute,
      );
    },
  );

  test(
    'analytics and history aggregate unique completions by completion day',
    () {
      final now = DateTime.now();
      final first = WorkoutSession.fromMap('same-id', {
        'name': 'Short workout',
        'status': 'completed',
        'completedAt': now,
        'startedAt': now.subtract(const Duration(seconds: 45)),
        'weekStart': now.subtract(Duration(days: now.weekday - 1)),
        'dayIndex': now.weekday - 1,
        'durationSeconds': 45,
        'durationMinutes': 1,
        'calories': 5,
        'exercises': [],
      });
      final duplicate = first.copyWith(durationSeconds: 45);
      final metrics = ProgressMetrics([first, duplicate]);

      expect(metrics.completedCount, 1);
      expect(metrics.historyCompletedCount, 1);
      expect(metrics.totalDurationSeconds, 45);
      expect(metrics.dailyActiveSeconds[now.weekday - 1], 45);
      expect(metrics.dailyActiveMinutes[now.weekday - 1], 1);
      expect(metrics.totalCalories, 5);
      expect(metrics.historyDurationSeconds, 45);
      expect(
        first.displayDate,
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}',
      );
    },
  );

  test('monthly activity uses completion dates rather than plan dates', () {
    final now = DateTime.now();
    final currentMonth = WorkoutSession.fromMap('this-month', {
      'name': 'Current month workout',
      'status': 'completed',
      'completedAt': now,
      'weekStart': DateTime(now.year, now.month - 1, 1),
      'durationSeconds': 90,
      'calories': 0,
      'exercises': [],
    });
    final previousMonthDate = DateTime(now.year, now.month - 1, 15);
    final previousMonth = WorkoutSession.fromMap('last-month', {
      'name': 'Previous month workout',
      'status': 'completed',
      'completedAt': previousMonthDate,
      'durationSeconds': 60,
      'calories': 6,
      'exercises': [],
    });
    final metrics = ProgressMetrics([currentMonth, previousMonth]);

    expect(metrics.monthlyCompletedCount, 1);
    expect(metrics.monthlyDurationSeconds, 90);
    expect(metrics.monthlyCalories, 9);
    expect(currentMonth.calories, 9);
  });
}
