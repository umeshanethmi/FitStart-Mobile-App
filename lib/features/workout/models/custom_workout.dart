import 'package:fitstart_mobile_app/models/exercise.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';

class CustomWorkout {
  final String id;
  final String name;
  final String level;
  final List<Exercise> exercises;
  final int? plannedDurationMinutes;

  CustomWorkout({
    required this.id,
    required this.name,
    required this.level,
    required List<Exercise> exercises,
    this.plannedDurationMinutes,
  }) : exercises = List.unmodifiable(exercises);

  factory CustomWorkout.fromWorkoutPlan({
    required String id,
    required WorkoutPlan plan,
  }) {
    return CustomWorkout(
      id: id,
      name: plan.name,
      level: plan.difficulty,
      exercises: plan.exercises,
      plannedDurationMinutes: plan.durationMinutes,
    );
  }

  int get durationMinutes {
    if (plannedDurationMinutes case final minutes?) return minutes;
    final seconds = exercises.fold<int>(
      0,
      (total, exercise) =>
          total +
          exercise.sets *
              ((exercise.durationSeconds ?? ((exercise.reps ?? 0) * 3)) +
                  exercise.restSeconds),
    );
    return (seconds / 60).ceil().clamp(1, 999);
  }

  WorkoutPlan toWorkoutPlan() {
    return WorkoutPlan(
      name: name,
      durationMinutes: durationMinutes,
      difficulty: level,
      exercises: exercises,
    );
  }
}
