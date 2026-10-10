import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitstart_mobile_app/features/workout/data/custom_workout_repository.dart';
import 'package:fitstart_mobile_app/features/workout/models/custom_workout.dart';

final customWorkoutRepositoryProvider = Provider<CustomWorkoutRepository>(
  (ref) => CustomWorkoutRepository(),
);

final workoutByIdProvider = FutureProvider.family<CustomWorkout?, String>(
  (ref, id) => ref.watch(customWorkoutRepositoryProvider).getById(id),
);

final customWorkoutsProvider =
    AsyncNotifierProvider<CustomWorkoutsNotifier, List<CustomWorkout>>(
      CustomWorkoutsNotifier.new,
    );

class CustomWorkoutsNotifier extends AsyncNotifier<List<CustomWorkout>> {
  CustomWorkoutRepository get _repository =>
      ref.read(customWorkoutRepositoryProvider);

  @override
  Future<List<CustomWorkout>> build() => _repository.getAll();

  Future<CustomWorkout> createWorkout(CustomWorkout workout) async {
    try {
      final created = await _repository.create(workout);
      state = AsyncData(await _repository.getAll());
      return created;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<CustomWorkout> updateWorkout(CustomWorkout workout) async {
    try {
      final updated = await _repository.update(workout);
      ref.invalidate(workoutByIdProvider(workout.id));
      state = AsyncData(await _repository.getAll());
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<CustomWorkout> deleteWorkout(String id) async {
    try {
      final deleted = await _repository.delete(id);
      ref.invalidate(workoutByIdProvider(id));
      state = AsyncData(await _repository.getAll());
      return deleted;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> restoreWorkout(CustomWorkout workout) async {
    try {
      await _repository.restore(workout);
      ref.invalidate(workoutByIdProvider(workout.id));
      state = AsyncData(await _repository.getAll());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.getAll());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
