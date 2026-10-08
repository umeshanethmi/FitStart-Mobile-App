import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/progress_data_view.dart';
import 'package:fitstart_mobile_app/screens/workout_detail_screen.dart';

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return ProgressDataView(
      builder: (context, workouts) {
        final metrics = ProgressMetrics(workouts);
        final previous = metrics.previousWeekActiveMinutes;
        final difference = metrics.totalDurationMinutes - previous;
        final percent = previous == 0
            ? 0
            : (difference * 100 / previous).round();
        final total = metrics.totalDurationMinutes + previous;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FD),
          appBar: AppBar(
            title: const Text('Activity details'),
            backgroundColor: const Color(0xFFF6F8FD),
            foregroundColor: _navy,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                'This week’s activity',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Review your completed workouts and active time.',
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Workouts completed',
                      '${metrics.completedCount}',
                      'of ${ProgressData.workoutGoal} weekly goal',
                      Icons.fitness_center_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      'Total active time',
                      _duration(metrics.totalDurationMinutes),
                      'this week',
                      Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _comparisonCard(metrics, difference, percent, total),
              const SizedBox(height: 20),
              const Text(
                'Recent workout sessions',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...metrics.completed.map(
                (workout) => _sessionCard(context, workout),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, String detail, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 21),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard(
    ProgressMetrics metrics,
    int difference,
    int changePercent,
    int total,
  ) {
    final isIncrease = difference >= 0;
    final progress = total == 0 ? 0.0 : metrics.totalDurationMinutes / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Week-over-week activity',
            style: TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _comparisonValue('This week', metrics.totalDurationMinutes),
              _comparisonValue(
                metrics.hasPreviousWeekData ? 'Last week' : 'Sample last week',
                metrics.previousWeekActiveMinutes,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEFA),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isIncrease
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isIncrease ? const Color(0xFF16A34A) : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${isIncrease ? '+' : ''}$difference min ($changePercent%) from last week',
                style: TextStyle(
                  color: isIncrease
                      ? const Color(0xFF15803D)
                      : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Average workout duration: ${metrics.averageWorkoutMinutes} min',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _comparisonValue(String label, int minutes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          _duration(minutes),
          style: const TextStyle(
            color: _navy,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _sessionCard(BuildContext context, WorkoutSession workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(workout.icon, color: workout.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${workout.date} · ${workout.durationMinutes} min',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${workout.calories} kcal',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
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
