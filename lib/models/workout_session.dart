import 'package:flutter/material.dart';

import 'training_workout_plan.dart';
import 'progress_data.dart' as progress_data;

typedef WorkoutCompletionHandler = Future<String?> Function(
  WorkoutSession session,
);

class WorkoutSession {
  final TrainingWorkoutPlan plan;
  final WorkoutCompletionHandler? onCompleted;
  DateTime? _startedAt;
  final Map<int, int> _completedSets = {};
  final Set<int> _completedExercises = {};
  DateTime? completedAt;
  String? completionRecordId;

  WorkoutSession({required this.plan, this._startedAt, this.onCompleted});

  DateTime? get startedAt => _startedAt;

  bool get isStarted => _startedAt != null;

  bool get isFinished => completedAt != null;

  void start({DateTime? at}) {
    _startedAt ??= at ?? DateTime.now();
  }

  int completedSetsFor(int exerciseIndex) => _completedSets[exerciseIndex] ?? 0;

  bool isExerciseComplete(int exerciseIndex) =>
      _completedExercises.contains(exerciseIndex);

  int get completedExerciseCount => _completedExercises.length;

  int get completedSetCount =>
      _completedSets.values.fold(0, (total, count) => total + count);

  double get progress => completedExerciseCount / plan.exercises.length;

  void completeSet(int exerciseIndex) {
    if (isFinished) return;
    if (isExerciseComplete(exerciseIndex)) return;

    final exercise = plan.exercises[exerciseIndex];
    final completedSets = completedSetsFor(exerciseIndex);
    if (completedSets >= exercise.sets) return;

    final updatedCount = completedSets + 1;
    _completedSets[exerciseIndex] = updatedCount;

    if (updatedCount == exercise.sets) {
      _completedExercises.add(exerciseIndex);
    }
  }

  Duration get elapsed {
    final startTime = _startedAt;
    if (startTime == null) return Duration.zero;
    return (completedAt ?? DateTime.now()).difference(startTime);
  }

  void finish({DateTime? at}) {
    start();
    completedAt ??= at ?? DateTime.now();
  }

  Map<String, dynamic> toProgressRecord() {
    final finishedAt = completedAt;
    if (finishedAt == null) {
      throw StateError('Finish the workout before saving its progress.');
    }
    if (plan.exercises.isEmpty ||
        completedExerciseCount != plan.exercises.length) {
      throw StateError(
        'Complete every exercise before saving workout progress.',
      );
    }
    final startTime = startedAt;
    if (startTime == null) {
      throw StateError('Start the workout before saving its progress.');
    }

    final workoutDay = DateTime(
      finishedAt.year,
      finishedAt.month,
      finishedAt.day,
    );
    final dayIndex = finishedAt.weekday - 1;
    final elapsedMilliseconds = elapsed.inMilliseconds;
    final durationSeconds = elapsedMilliseconds == 0
        ? 0
        : (elapsedMilliseconds / 1000).ceil();
    final durationMinutes = (durationSeconds / 60).ceil();
    return {
      'name': plan.name,
      'date': progress_data.ProgressData.dayLabels[dayIndex],
      'dayIndex': dayIndex,
      'weekStart': workoutDay.subtract(Duration(days: dayIndex)),
      'completedAt': finishedAt,
      'durationMinutes': durationMinutes,
      'durationSeconds': durationSeconds,
      'calories': progress_data.ProgressData.estimatedCaloriesForSeconds(
        durationSeconds,
      ),
      'iconCodePoint': Icons.fitness_center_rounded.codePoint,
      'colorValue': const Color(0xFF2563EB).toARGB32(),
      'status': progress_data.WorkoutStatus.completed.name,
      'exercises': [
        for (var index = 0; index < plan.exercises.length; index++)
          {
            'id': plan.exercises[index].name,
            'name': plan.exercises[index].name,
            'sets': plan.exercises[index].sets,
            'reps': plan.exercises[index].reps ?? 1,
            'repsLabel': plan.exercises[index].durationSeconds == null
                ? null
                : '${plan.exercises[index].durationSeconds} sec',
            'restSeconds': plan.exercises[index].restSeconds,
            'isCompleted': isExerciseComplete(index),
          },
      ],
      'startedAt': startTime,
      'sortOrder': 0,
    };
  }
}
