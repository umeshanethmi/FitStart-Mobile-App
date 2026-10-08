import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/progress_data_view.dart';

class ProgressDetailsScreen extends StatelessWidget {
  const ProgressDetailsScreen({super.key});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return ProgressDataView(
      builder: (context, workouts) {
        final metrics = ProgressMetrics(workouts);
        final progress = metrics.completedCount / ProgressData.workoutGoal;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FD),
          appBar: AppBar(
            title: const Text('Progress details'),
            backgroundColor: const Color(0xFFF6F8FD),
            foregroundColor: _navy,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                'Your weekly goal',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Small steps add up. Here is your progress so far.',
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 20),
              _goalCard(metrics, progress),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _countCard(
                      'Completed workouts',
                      metrics.completedCount,
                      Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _countCard(
                      'Planned workouts',
                      metrics.planned.length,
                      Icons.event_available_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Progress breakdown',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _metricCard(
                icon: Icons.check_circle_outline_rounded,
                label: 'Workout completion',
                value: '${metrics.workoutCompletionPercent}%',
                progress: progress,
              ),
              const SizedBox(height: 12),
              _metricCard(
                icon: Icons.flag_outlined,
                label: 'Weekly workout goal',
                value:
                    '${metrics.completedCount} of ${ProgressData.workoutGoal} workouts',
                progress: progress,
              ),
              const SizedBox(height: 12),
              _metricCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Current streak',
                value: '${metrics.currentStreak} days',
                progress: (metrics.currentStreak / 5).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 12),
              _metricCard(
                icon: Icons.schedule_rounded,
                label: 'Active time this week',
                value: _duration(metrics.totalDurationMinutes),
                progress: (metrics.totalDurationMinutes / 300).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 18),
              _encouragement(metrics),
            ],
          ),
        );
      },
    );
  }

  Widget _goalCard(ProgressMetrics metrics, double progress) {
    final remaining = (ProgressData.workoutGoal - metrics.completedCount).clamp(
      0,
      100,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Workout completion',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${metrics.completedCount}/${ProgressData.workoutGoal}',
                style: const TextStyle(
                  color: _blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(
                        value: metrics.workoutCompletionPercent / 100,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFE8EEFA),
                        valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                      ),
                    ),
                    Text(
                      '${metrics.workoutCompletionPercent}%',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Text(
                  'Overall progress toward your weekly fitness goal.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEFA),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remaining == 0
                ? 'Weekly workout goal reached!'
                : '$remaining workout${remaining == 1 ? '' : 's'} left to reach your weekly goal',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _countCard(String label, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: _blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: _blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFE8EEFA),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encouragement(ProgressMetrics metrics) {
    final remaining = (ProgressData.workoutGoal - metrics.completedCount).clamp(
      0,
      100,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: _blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              remaining == 0
                  ? 'You have reached your weekly workout target. Keep it up!'
                  : 'You are $remaining workout${remaining == 1 ? '' : 's'} away from your weekly target.',
              style: const TextStyle(
                color: _navy,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _duration(int minutes) => '${minutes ~/ 60}h ${minutes % 60}m';

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
