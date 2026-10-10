import 'exercise.dart';
import 'scheduled_workout.dart';
import 'workout_plan.dart';

class TrainingWorkoutPlan {
  final String name;
  final int durationMinutes;
  final String difficulty;
  final List<Exercise> exercises;
  final bool durationIsEstimate;

  const TrainingWorkoutPlan({
    required this.name,
    required this.durationMinutes,
    required this.difficulty,
    required this.exercises,
    this.durationIsEstimate = false,
  });

  factory TrainingWorkoutPlan.fromScheduledWorkout(ScheduledWorkout workout) {
    if (workout.exercises.isEmpty) {
      throw const FormatException('This scheduled workout has no exercises.');
    }
    final exercises = workout.exercises
        .map((data) {
          final name = WorkoutPlan.exerciseName(data);
          final sets = _number(data['sets'], '$name: sets');
          final rest = _number(
            data['restSeconds'],
            '$name: rest time',
            allowZero: true,
          );
          final duration = data['durationSeconds'] == null
              ? null
              : _number(data['durationSeconds'], '$name: duration');
          final reps = duration == null
              ? _number(data['reps'], '$name: repetitions')
              : null;
          return Exercise(
            name: name,
            description:
                data['description'] as String? ??
                '$sets sets of ${duration == null ? '$reps repetitions' : '$duration seconds'}. Rest $rest seconds between sets.',
            targetArea: data['targetArea'] as String? ?? 'Not specified',
            sets: sets,
            reps: reps,
            durationSeconds: duration,
            restSeconds: rest,
            beginnerTip: data['beginnerTip'] as String? ?? '',
          );
        })
        .toList(growable: false);
    final target = workout.preferences['durationMinutes'];
    final hasTarget = target is int && target > 0;
    final estimatedSeconds = exercises.fold<int>(
      0,
      (total, exercise) =>
          total +
          exercise.sets *
              ((exercise.durationSeconds ?? exercise.reps! * 3) +
                  exercise.restSeconds),
    );
    return TrainingWorkoutPlan(
      name: workout.title,
      durationMinutes: hasTarget ? target : (estimatedSeconds / 60).ceil(),
      durationIsEstimate: !hasTarget,
      difficulty:
          workout.preferences['experience'] as String? ?? 'Scheduled workout',
      exercises: List.unmodifiable(exercises),
    );
  }

  static int _number(Object? value, String label, {bool allowZero = false}) {
    if (value is! num ||
        !value.isFinite ||
        value != value.toInt() ||
        value < (allowZero ? 0 : 1)) {
      throw FormatException(
        'Invalid $label. Update the workout before starting.',
      );
    }
    return value.toInt();
  }

  static const beginnerSample = TrainingWorkoutPlan(
    name: 'Beginner Full-Body',
    durationMinutes: 20,
    difficulty: 'Beginner',
    exercises: [
      Exercise(
        name: 'Bodyweight Squat',
        description:
            'Sit your hips back as if lowering onto a chair, then stand tall.',
        targetArea: 'Legs and glutes',
        sets: 3,
        reps: 10,
        restSeconds: 45,
        beginnerTip: 'Keep your chest lifted and move at a comfortable pace.',
      ),
      Exercise(
        name: 'Wall Push-Up',
        description:
            'Place your hands on a wall and bend your elbows to bring your '
            'chest toward it, then gently push away.',
        targetArea: 'Chest, shoulders, and arms',
        sets: 3,
        reps: 8,
        restSeconds: 45,
        beginnerTip: 'Stand closer to the wall to make this movement easier.',
      ),
      Exercise(
        name: 'Glute Bridge',
        description:
            'Lie on your back with knees bent, then lift your hips and lower '
            'them with control.',
        targetArea: 'Glutes and core',
        sets: 3,
        reps: 12,
        restSeconds: 45,
        beginnerTip: 'Keep your feet flat and avoid arching your lower back.',
      ),
      Exercise(
        name: 'Standing March',
        description:
            'Stand tall and gently lift one knee at a time, alternating sides.',
        targetArea: 'Core and legs',
        sets: 3,
        durationSeconds: 30,
        restSeconds: 45,
        beginnerTip: 'Use a wall or sturdy chair for balance if needed.',
      ),
    ],
  );
}
