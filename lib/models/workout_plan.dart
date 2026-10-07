import 'exercise.dart';

class WorkoutPlan {
  final String name;
  final int durationMinutes;
  final String difficulty;
  final List<Exercise> exercises;

  const WorkoutPlan({
    required this.name,
    required this.durationMinutes,
    required this.difficulty,
    required this.exercises,
  });

  static const beginnerSample = WorkoutPlan(
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
        beginnerTip:
            'Stand closer to the wall to make this movement easier.',
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
