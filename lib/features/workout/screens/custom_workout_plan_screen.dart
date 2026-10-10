import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitstart_mobile_app/features/workout/providers/custom_workout_provider.dart';
import 'package:fitstart_mobile_app/screens/daily_workout_plan_screen.dart';

class CustomWorkoutPlanScreen extends ConsumerWidget {
  const CustomWorkoutPlanScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutByIdProvider(workoutId));
    return workout.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Workout Plan')),
        body: Center(child: Text('Could not load workout: $error')),
      ),
      data: (value) => value == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Workout Plan')),
              body: const Center(child: Text('Workout not found.')),
            )
          : DailyWorkoutPlanScreen(plan: value.toWorkoutPlan()),
    );
  }
}
