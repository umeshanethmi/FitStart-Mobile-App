import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  const ExerciseDetailsScreen({
    super.key,
    required this.workout,
    required this.exercise,
  });

  final WorkoutSession workout;
  final WorkoutExercise exercise;

  static const Color _navy = Color(0xFF0F172A);
  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Exercise details'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: _blue,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _statusLabel(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  'Sets',
                  '${exercise.sets}',
                  Icons.repeat_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  'Reps',
                  exercise.repsLabel ?? '${exercise.reps}',
                  Icons.fitness_center_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricCard(
            'Rest time',
            exercise.restSeconds == 0
                ? 'No rest specified'
                : '${exercise.restSeconds} sec',
            Icons.hourglass_bottom_rounded,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: _blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Exercise progress is provided by the workout module. Status: ${_workoutStatusLabel()}.',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 19),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _workoutStatusLabel() => switch (workout.status) {
    WorkoutStatus.completed => 'completed',
    WorkoutStatus.inProgress => 'in progress',
    WorkoutStatus.cancelled => 'cancelled',
    WorkoutStatus.planned => 'planned',
  };

  Widget _statusLabel() {
    final isCompleted = exercise.isCompleted;
    final color = isCompleted
        ? const Color(0xFF15803D)
        : workout.isStarted
        ? _blue
        : const Color(0xFF64748B);
    final background = isCompleted
        ? const Color(0xFFECFDF3)
        : workout.isStarted
        ? const Color(0xFFEAF1FF)
        : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'Not completed',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
