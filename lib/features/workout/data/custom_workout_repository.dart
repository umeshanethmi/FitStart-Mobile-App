import 'package:fitstart_mobile_app/features/workout/models/custom_workout.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';

class CustomWorkoutRepository {
  CustomWorkoutRepository({List<CustomWorkout>? initialWorkouts})
    : _workouts = {
        for (final workout in initialWorkouts ?? [_beginnerWorkout()])
          workout.id: workout,
      };

  final Map<String, CustomWorkout> _workouts;
  static var _nextId = 0;

  static CustomWorkout _beginnerWorkout() =>
      CustomWorkout.fromWorkoutPlan(
        id: 'beginner-full-body',
        plan: WorkoutPlan.beginnerSample,
      );

  Future<List<CustomWorkout>> getAll() async =>
      List.unmodifiable(_workouts.values);

  Future<CustomWorkout?> getById(String id) async => _workouts[id];

  Future<CustomWorkout> create(CustomWorkout workout) async {
    final id = workout.id.isEmpty
        ? 'custom-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}'
        : workout.id;
    if (_workouts.containsKey(id)) {
      throw StateError('A workout with id "$id" already exists.');
    }

    final created = CustomWorkout(
      id: id,
      name: workout.name,
      level: workout.level,
      exercises: workout.exercises,
      plannedDurationMinutes: workout.plannedDurationMinutes,
    );
    _workouts[id] = created;
    return created;
  }

  Future<CustomWorkout> update(CustomWorkout workout) async {
    if (!_workouts.containsKey(workout.id)) {
      throw StateError('Workout "${workout.id}" does not exist.');
    }
    _workouts[workout.id] = workout;
    return workout;
  }

  Future<CustomWorkout> delete(String id) async {
    final workout = _workouts.remove(id);
    if (workout == null) {
      throw StateError('Workout "$id" does not exist.');
    }
    return workout;
  }

  Future<CustomWorkout> restore(CustomWorkout workout) async {
    if (_workouts.containsKey(workout.id)) {
      throw StateError('A workout with id "${workout.id}" already exists.');
    }
    _workouts[workout.id] = workout;
    return workout;
  }
}
