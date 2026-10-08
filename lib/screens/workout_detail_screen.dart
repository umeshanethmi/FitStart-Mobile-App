import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/exercise_details_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});

  final WorkoutSession workout;

  static const Color _navy = Color(0xFF0F172A);
  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Workout details'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _headerCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: workout.date.isEmpty
                      ? 'Date unavailable'
                      : workout.date,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: workout.isCompleted
                      ? '${workout.durationMinutes} min'
                      : 'Not recorded',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Calories burned',
            value: workout.isCompleted
                ? '${workout.calories} kcal'
                : 'Not recorded',
          ),
          const SizedBox(height: 22),
          const Text(
            'Exercise summary',
            style: TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _exerciseSummary(context),
          if (workout.isCompleted && workout.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _readOnlyCard(
              title: 'Workout notes',
              icon: Icons.notes_rounded,
              child: Text(
                workout.notes,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
          if (workout.isCompleted && workout.rating > 0) ...[
            const SizedBox(height: 12),
            _readOnlyCard(
              title: 'Workout rating',
              icon: Icons.star_rounded,
              child: Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < workout.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${workout.rating}/5',
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: workout.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(workout.icon, color: workout.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _statusLabel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseSummary(BuildContext context) {
    if (workout.exerciseSummary.isEmpty) {
      return _readOnlyCard(
        title: 'No exercise details available',
        icon: Icons.info_outline_rounded,
        child: Text(
          'Exercise details will appear here when they are saved by the workout module.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var index = 0; index < workout.exerciseSummary.length; index++)
            _exerciseRow(
              context,
              workout.exerciseSummary[index],
              index,
              index < workout.exerciseSummary.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _exerciseRow(
    BuildContext context,
    WorkoutExercise exercise,
    int index,
    bool showDivider,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    ExerciseDetailsScreen(workout: workout, exercise: exercise),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF1FF),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${exercise.sets} sets · ${exercise.repsLabel ?? '${exercise.reps} reps'}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    exercise.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: exercise.isCompleted
                        ? const Color(0xFF16A34A)
                        : Colors.grey.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }

  Widget _statusLabel() {
    final (label, color, background) = switch (workout.status) {
      WorkoutStatus.completed => (
        'Completed',
        const Color(0xFF15803D),
        const Color(0xFFECFDF3),
      ),
      WorkoutStatus.inProgress => (
        'In progress',
        _blue,
        const Color(0xFFEAF1FF),
      ),
      WorkoutStatus.cancelled => (
        'Cancelled',
        const Color(0xFF64748B),
        const Color(0xFFF1F5F9),
      ),
      WorkoutStatus.planned => (
        'Planned',
        const Color(0xFF64748B),
        const Color(0xFFF1F5F9),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _readOnlyCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _blue, size: 20),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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
