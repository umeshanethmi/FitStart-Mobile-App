import 'workout_plan.dart';

class WorkoutSession {
  final WorkoutPlan plan;
  final DateTime startedAt;
  final Map<int, int> _completedSets = {};
  final Set<int> _completedExercises = {};
  final Set<int> _skippedExercises = {};
  DateTime? completedAt;

  WorkoutSession({
    required this.plan,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  int completedSetsFor(int exerciseIndex) =>
      _completedSets[exerciseIndex] ?? 0;

  bool isExerciseComplete(int exerciseIndex) =>
      _completedExercises.contains(exerciseIndex);

  bool isExerciseSkipped(int exerciseIndex) =>
      _skippedExercises.contains(exerciseIndex);

  int get completedExerciseCount => _completedExercises.length;

  int get skippedExerciseCount => _skippedExercises.length;

  int get completedSetCount =>
      _completedSets.values.fold(0, (total, count) => total + count);

  double get progress =>
      completedExerciseCount / plan.exercises.length;

  void completeSet(int exerciseIndex) {
    if (isExerciseComplete(exerciseIndex) || isExerciseSkipped(exerciseIndex)) {
      return;
    }

    final exercise = plan.exercises[exerciseIndex];
    final completedSets = completedSetsFor(exerciseIndex);
    if (completedSets >= exercise.sets) return;

    final updatedCount = completedSets + 1;
    _completedSets[exerciseIndex] = updatedCount;

    if (updatedCount == exercise.sets) {
      _completedExercises.add(exerciseIndex);
    }
  }

  void skipExercise(int exerciseIndex) {
    if (isExerciseComplete(exerciseIndex) || isExerciseSkipped(exerciseIndex)) {
      return;
    }

    _skippedExercises.add(exerciseIndex);
  }

  Duration get elapsed =>
      (completedAt ?? DateTime.now()).difference(startedAt);

  void finish() {
    completedAt ??= DateTime.now();
  }
}
