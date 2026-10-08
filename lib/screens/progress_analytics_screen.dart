import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/activity_details_screen.dart';
import 'package:fitstart_mobile_app/screens/achievements_screen.dart';
import 'package:fitstart_mobile_app/screens/calories_details_screen.dart';
import 'package:fitstart_mobile_app/screens/progress_data_view.dart';
import 'package:fitstart_mobile_app/screens/progress_details_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_detail_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_history_screen.dart';

class ProgressAnalyticsScreen extends StatelessWidget {
  const ProgressAnalyticsScreen({super.key});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return ProgressDataView(
      builder: (context, workouts) {
        final isDemoData = workouts.isEmpty;
        final dashboardWorkouts = isDemoData
            ? ProgressData.sampleWorkouts
            : workouts;
        final metrics = ProgressMetrics(dashboardWorkouts);
        final recentWorkouts = dashboardWorkouts
            .where((workout) => !workout.isCancelled)
            .take(3)
            .toList();
        final activeDifference =
            metrics.totalDurationMinutes - metrics.previousWeekActiveMinutes;
        final comparisonLabel = isDemoData
            ? 'preview baseline'
            : metrics.hasPreviousWeekData
            ? 'last week'
            : 'baseline';
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FD),
          appBar: AppBar(
            title: const Text(
              'Progress & Analytics',
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: const Color(0xFFF6F8FD),
            foregroundColor: _navy,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Achievements & Rewards',
                icon: const Icon(Icons.emoji_events_outlined),
                onPressed: () =>
                    _openScreen(context, const AchievementsScreen()),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                'Your fitness journey',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A look at your activity and progress this week.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (isDemoData) ...[const SizedBox(height: 10), _demoDataLabel()],
              const SizedBox(height: 20),
              _overallProgressCard(context, metrics),
              const SizedBox(height: 20),
              const Text(
                'Activity summary',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _workoutsCard(context, metrics)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.timer_outlined,
                      label: 'Active time',
                      value: _duration(metrics.totalDurationMinutes),
                      detail:
                          '${activeDifference >= 0 ? '+' : ''}'
                          '$activeDifference min vs $comparisonLabel',
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _caloriesCard(context, metrics),
              const SizedBox(height: 22),
              const Text(
                'Weekly activity',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _weeklyChart(metrics, isDemoData: isDemoData),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent workouts',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _openScreen(context, const WorkoutHistoryScreen()),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentWorkouts.isEmpty)
                _emptyWorkoutsCard()
              else
                ...recentWorkouts.map(
                  (workout) => _recentWorkoutCard(context, workout),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _overallProgressCard(BuildContext context, ProgressMetrics metrics) {
    return _interactiveCard(
      onTap: () => _openScreen(context, const ProgressDetailsScreen()),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            height: 94,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: metrics.workoutCompletionPercent / 100,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFE8EEFA),
                    valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${metrics.workoutCompletionPercent}%',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'of goal',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall progress',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'You’re building a great routine. Keep going to reach your weekly target!',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${metrics.completedCount} of ${ProgressData.workoutGoal} workouts completed',
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _workoutsCard(BuildContext context, ProgressMetrics metrics) {
    return _interactiveCard(
      onTap: () => _openScreen(context, const ActivityDetailsScreen()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fitness_center_rounded, color: _blue, size: 21),
          const SizedBox(height: 12),
          Text(
            'Workouts',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${metrics.completedCount}',
            style: const TextStyle(
              color: _navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'of ${ProgressData.workoutGoal} planned',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required String detail,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _caloriesCard(BuildContext context, ProgressMetrics metrics) {
    return _interactiveCard(
      onTap: () => _openScreen(context, const CaloriesDetailsScreen()),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFF59E0B),
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Calories burned',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${metrics.totalCalories}',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'kcal this week',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Text(
                '${metrics.calorieGoalPercent}% of goal',
                style: const TextStyle(
                  color: _blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (metrics.totalCalories / ProgressData.weeklyCalorieGoal)
                  .clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEFA),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyChart(ProgressMetrics metrics, {required bool isDemoData}) {
    final maxMinutes = metrics.dailyActiveMinutes.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final mostActiveDay = metrics.mostActiveDayIndex;
    final difference =
        metrics.totalDurationMinutes - metrics.previousWeekActiveMinutes;
    final comparisonLabel = isDemoData
        ? 'preview baseline'
        : metrics.hasPreviousWeekData
        ? 'last week'
        : 'baseline';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _duration(metrics.totalDurationMinutes),
            style: const TextStyle(
              color: _navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${difference >= 0 ? '+' : ''}$difference min vs $comparisonLabel',
            style: TextStyle(
              color: difference >= 0
                  ? const Color(0xFF15803D)
                  : Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 126,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final minutes = metrics.dailyActiveMinutes[index];
                final isMostActive = maxMinutes > 0 && index == mostActiveDay;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 18,
                          child: isMostActive
                              ? const Text(
                                  'MOST',
                                  style: TextStyle(
                                    color: _blue,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : null,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: maxMinutes == 0
                                  ? 0
                                  : minutes / maxMinutes,
                              child: Container(
                                width: 18,
                                decoration: BoxDecoration(
                                  color: isMostActive
                                      ? _blue
                                      : const Color(0xFFBFD4FF),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ProgressData.dayLabels[index],
                          style: TextStyle(
                            color: isMostActive ? _blue : Colors.grey.shade500,
                            fontSize: 10,
                            fontWeight: isMostActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            maxMinutes == 0
                ? 'Complete a workout to see your most active day.'
                : 'Most active: ${ProgressData.dayLabels[mostActiveDay]} · $maxMinutes minutes',
            style: const TextStyle(
              color: _blue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentWorkoutCard(BuildContext context, WorkoutSession workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: _interactiveCard(
        onTap: () =>
            _openScreen(context, WorkoutDetailScreen(workout: workout)),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(workout.icon, color: workout.color, size: 22),
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
                  Text(
                    '${workout.date} · ${workout.isCompleted ? '${workout.durationMinutes} min' : workout.status.name}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _emptyWorkoutsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.fitness_center_rounded, color: _blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No workout history yet. Completed and planned workouts will appear here.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoDataLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Demo data · replaced when your workouts are available',
          style: TextStyle(
            color: _blue,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _interactiveCard({
    required Widget child,
    required VoidCallback onTap,
    required EdgeInsetsGeometry padding,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
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

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => screen),
    );
  }

  String _duration(int minutes) => '${minutes ~/ 60}h ${minutes % 60}m';
}
