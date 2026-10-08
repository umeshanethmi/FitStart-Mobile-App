import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';
import 'package:fitstart_mobile_app/screens/progress_data_view.dart';

class CaloriesDetailsScreen extends StatelessWidget {
  const CaloriesDetailsScreen({super.key});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return ProgressDataView(
      builder: (context, workouts) {
        final metrics = ProgressMetrics(workouts);
        final highestDay = metrics.highestCalorieDayIndex;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FD),
          appBar: AppBar(
            title: const Text('Calories details'),
            backgroundColor: const Color(0xFFF6F8FD),
            foregroundColor: _navy,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const Text(
                'Calories burned',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track your weekly effort and calorie goal.',
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 20),
              _summaryCard(metrics),
              const SizedBox(height: 18),
              const Text(
                'Daily breakdown',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _dailyChart(metrics, highestDay),
              const SizedBox(height: 18),
              const Text(
                'Calories by day',
                style: TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                ProgressData.dayLabels.length,
                (index) => _dailyRow(metrics, index, highestDay),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(ProgressMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Total burned this week',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${metrics.totalCalories}',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 5),
                child: Text(
                  'kcal',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Weekly goal: ${ProgressData.weeklyCalorieGoal} kcal',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (metrics.totalCalories / ProgressData.weeklyCalorieGoal)
                  .clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: const Color(0xFFE8EEFA),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${metrics.calorieGoalPercent}% completed',
            style: const TextStyle(
              color: _blue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyChart(ProgressMetrics metrics, int highestDay) {
    final maxCalories = metrics.dailyCalories.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: _cardDecoration(),
      child: SizedBox(
        height: 145,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(ProgressData.dayLabels.length, (index) {
            final calories = metrics.dailyCalories[index];
            final isHighest = maxCalories > 0 && index == highestDay;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    SizedBox(
                      height: 22,
                      child: FittedBox(
                        child: Text(
                          calories == 0 ? '–' : '$calories',
                          style: TextStyle(
                            color: isHighest ? _blue : Colors.grey.shade500,
                            fontSize: 10,
                            fontWeight: isHighest
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: maxCalories == 0
                              ? 0
                              : calories / maxCalories,
                          child: Container(
                            width: 18,
                            decoration: BoxDecoration(
                              color: isHighest
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
                        color: isHighest ? _blue : Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: isHighest
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
    );
  }

  Widget _dailyRow(ProgressMetrics metrics, int index, int highestDay) {
    final calories = metrics.dailyCalories[index];
    final isHighest = calories > 0 && index == highestDay;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ProgressData.dayLabels[index],
              style: const TextStyle(
                color: _navy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isHighest) ...[
            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 17),
            const SizedBox(width: 4),
            const Text(
              'Highest',
              style: TextStyle(
                color: Color(0xFFB45309),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            '$calories kcal',
            style: const TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
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
