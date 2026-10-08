import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/progress_data_view.dart';
import 'package:fitstart_mobile_app/screens/workout_detail_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  static const Color _navy = Color(0xFF0F172A);
  String _selectedFilter = 'All';

  List<WorkoutSession> _filteredWorkouts(List<WorkoutSession> workouts) {
    if (_selectedFilter == 'Completed') {
      return workouts.where((workout) => workout.isCompleted).toList();
    }
    if (_selectedFilter == 'Planned') {
      return workouts.where((workout) => workout.isPlanned).toList();
    }
    return workouts;
  }

  @override
  Widget build(BuildContext context) {
    return ProgressDataView(
      builder: (context, workouts) {
        final metrics = ProgressMetrics(workouts);
        final filteredWorkouts = _filteredWorkouts(workouts);
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FD),
          appBar: AppBar(
            title: const Text('Workout history'),
            backgroundColor: const Color(0xFFF6F8FD),
            foregroundColor: _navy,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                'Your sessions',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A record of your recent training activity.',
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 18),
              _summaryCards(metrics),
              const SizedBox(height: 22),
              _buildFilterChips(),
              const SizedBox(height: 14),
              if (filteredWorkouts.isEmpty)
                _emptyState()
              else
                ...filteredWorkouts.map(_workoutCard),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCards(ProgressMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.fitness_center_rounded,
            label: 'Workouts',
            value: '${metrics.totalWorkoutCount}',
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _summaryCard(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '${metrics.historyDurationMinutes}m',
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _summaryCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Calories',
            value: '${metrics.historyCalories}',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['All', 'Completed', 'Planned'];
    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedFilter = filter),
          selectedColor: const Color(0xFFEAF1FF),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade200,
          ),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _workoutCard(WorkoutSession workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => WorkoutDetailScreen(workout: workout),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: workout.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(workout.icon, color: workout.color, size: 23),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workout.date,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusLabel(workout),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 13),
                Row(
                  children: [
                    _workoutFact(
                      Icons.timer_outlined,
                      workout.isCompleted
                          ? '${workout.durationMinutes} min'
                          : '—',
                    ),
                    const SizedBox(width: 20),
                    _workoutFact(
                      Icons.local_fire_department_outlined,
                      workout.isCompleted ? '${workout.calories} kcal' : '—',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.event_note_rounded, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 10),
          Text(
            'No $_selectedFilter workouts',
            style: const TextStyle(color: _navy, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _statusLabel(WorkoutSession workout) {
    final color = workout.isCompleted
        ? const Color(0xFF15803D)
        : workout.isStarted
        ? const Color(0xFF2563EB)
        : const Color(0xFF64748B);
    final background = workout.isCompleted
        ? const Color(0xFFECFDF3)
        : workout.isStarted
        ? const Color(0xFFEAF1FF)
        : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        switch (workout.status) {
          WorkoutStatus.completed => 'Completed',
          WorkoutStatus.inProgress => 'In progress',
          WorkoutStatus.planned => 'Planned',
          WorkoutStatus.cancelled => 'Cancelled',
        },
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _workoutFact(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 16),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
      ],
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
