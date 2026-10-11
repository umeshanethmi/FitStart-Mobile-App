import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/progress_data.dart';

enum AchievementCategory {
  workoutMilestones('Workout Milestones'),
  consistency('Consistency & Streaks'),
  calories('Calories Burned'),
  duration('Workout Duration'),
  personalBests('Personal Bests'),
  challenges('Special Challenges');

  const AchievementCategory(this.label);

  final String label;
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.requirement,
    required this.icon,
    required this.color,
    required this.points,
    required this.progressValue,
    required this.target,
    required this.progressLabel,
  });

  final String id;
  final AchievementCategory category;
  final String title;
  final String description;
  final String requirement;
  final IconData icon;
  final Color color;
  final int points;
  final double Function(AchievementProgress progress) progressValue;
  final double target;
  final String Function(AchievementProgress progress) progressLabel;

  double progressFor(AchievementProgress progress) =>
      (progressValue(progress) / target).clamp(0.0, 1.0);
}

class AchievementRecord {
  const AchievementRecord({
    required this.id,
    required this.earnedAt,
    required this.points,
  });

  final String id;
  final DateTime? earnedAt;
  final int points;

  factory AchievementRecord.fromMap(String id, Map<String, dynamic> data) {
    final value = data['earnedAt'];
    return AchievementRecord(
      id: id,
      earnedAt: value is Timestamp
          ? value.toDate()
          : value is DateTime
          ? value
          : value is String
          ? DateTime.tryParse(value)
          : null,
      points: data['rewardPoints'] is num
          ? (data['rewardPoints'] as num).toInt()
          : 0,
    );
  }
}

class AchievementProgress {
  AchievementProgress(Iterable<WorkoutSession> workouts)
    : completedWorkouts = _completedWorkouts(workouts),
      completedCalories = _sum(workouts, (workout) => workout.calories),
      completedMinutes = _sum(
        workouts,
        (workout) => workout.durationSeconds ~/ 60,
      ),
      longestWorkoutMinutes = _longestWorkout(workouts),
      longestStreakDays = _longestStreak(workouts),
      weekendDays = _bestWeekend(workouts);

  final List<WorkoutSession> completedWorkouts;
  final int completedCalories;
  final int completedMinutes;
  final int longestWorkoutMinutes;
  final int longestStreakDays;
  final int weekendDays;

  static List<WorkoutSession> _completedWorkouts(
    Iterable<WorkoutSession> workouts,
  ) {
    final unique = <String, WorkoutSession>{};
    for (final workout in workouts) {
      if (workout.isCompleted) unique[workout.id] = workout;
    }
    return unique.values.toList(growable: false);
  }

  static int _sum(
    Iterable<WorkoutSession> workouts,
    int Function(WorkoutSession) value,
  ) {
    return _completedWorkouts(workouts)
        .fold(0, (total, workout) => total + value(workout).clamp(0, 1 << 30));
  }

  static int _longestWorkout(Iterable<WorkoutSession> workouts) {
    return _completedWorkouts(workouts).fold(
      0,
      (longest, workout) => workout.durationSeconds ~/ 60 > longest
          ? workout.durationSeconds ~/ 60
          : longest,
    );
  }

  static Set<int> _completionDays(Iterable<WorkoutSession> workouts) {
    return _completedWorkouts(workouts)
        .map(
          (workout) =>
              workout.completedAt ?? workout.startedAt ?? workout.createdAt,
        )
        .whereType<DateTime>()
        .map(
          (date) =>
              DateTime.utc(
                date.year,
                date.month,
                date.day,
              ).millisecondsSinceEpoch ~/
              Duration.millisecondsPerDay,
        )
        .toSet();
  }

  static int _longestStreak(Iterable<WorkoutSession> workouts) {
    final days = _completionDays(workouts).toList()..sort();
    if (days.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var index = 1; index < days.length; index++) {
      if (days[index] == days[index - 1] + 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  static int _bestWeekend(Iterable<WorkoutSession> workouts) {
    final daysByWeek = <int, Set<int>>{};
    for (final workout in _completedWorkouts(workouts)) {
      final date =
          workout.completedAt ?? workout.startedAt ?? workout.createdAt;
      if (date == null) continue;
      final day = DateTime.utc(date.year, date.month, date.day);
      final dayNumber =
          day.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
      final monday = dayNumber - (day.weekday - 1);
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        daysByWeek.putIfAbsent(monday, () => <int>{}).add(day.weekday);
      }
    }
    return daysByWeek.values.fold(
      0,
      (best, days) => days.length > best ? days.length : best,
    );
  }
}

class AchievementCatalog {
  const AchievementCatalog._();

  static const definitions = <AchievementDefinition>[
    AchievementDefinition(
      id: 'first_workout',
      category: AchievementCategory.workoutMilestones,
      title: 'First Workout',
      description: 'Your fitness journey starts with one session.',
      requirement: 'Complete 1 workout.',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFF0D9488),
      points: 20,
      progressValue: _completedCount,
      target: 1,
      progressLabel: _completedCountLabel,
    ),
    AchievementDefinition(
      id: 'getting_started',
      category: AchievementCategory.workoutMilestones,
      title: 'Getting Started',
      description: 'Build momentum with five completed workouts.',
      requirement: 'Complete 5 workouts.',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF2563EB),
      points: 40,
      progressValue: _completedCount,
      target: 5,
      progressLabel: _completedCountLabel,
    ),
    AchievementDefinition(
      id: 'fitness_champion',
      category: AchievementCategory.workoutMilestones,
      title: 'Fitness Champion',
      description: 'A major milestone on your fitness journey.',
      requirement: 'Complete 25 workouts.',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFF7C3AED),
      points: 100,
      progressValue: _completedCount,
      target: 25,
      progressLabel: _completedCountLabel,
    ),
    AchievementDefinition(
      id: 'consistency_star',
      category: AchievementCategory.consistency,
      title: 'Consistency Star',
      description: 'Show up three days in a row.',
      requirement: 'Complete workouts on 3 consecutive days.',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEA580C),
      points: 40,
      progressValue: _streakCount,
      target: 3,
      progressLabel: _streakLabel,
    ),
    AchievementDefinition(
      id: 'weekly_warrior',
      category: AchievementCategory.consistency,
      title: 'Weekly Warrior',
      description: 'Keep your training streak alive for a full week.',
      requirement: 'Complete workouts on 7 consecutive days.',
      icon: Icons.bolt_rounded,
      color: Color(0xFFDB2777),
      points: 100,
      progressValue: _streakCount,
      target: 7,
      progressLabel: _streakLabel,
    ),
    AchievementDefinition(
      id: 'calorie_burner',
      category: AchievementCategory.calories,
      title: 'Calorie Burner',
      description: 'Burn your first thousand calories across workouts.',
      requirement: 'Burn 1,000 calories in completed workouts.',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFF59E0B),
      points: 50,
      progressValue: _calorieCount,
      target: 1000,
      progressLabel: _calorieLabel,
    ),
    AchievementDefinition(
      id: 'endurance_master',
      category: AchievementCategory.duration,
      title: 'Endurance Master',
      description: 'Put in ten hours of completed workout time.',
      requirement: 'Complete 600 total workout minutes.',
      icon: Icons.timer_rounded,
      color: Color(0xFF0891B2),
      points: 60,
      progressValue: _minuteCount,
      target: 600,
      progressLabel: _minuteLabel,
    ),
    AchievementDefinition(
      id: 'long_haul',
      category: AchievementCategory.personalBests,
      title: 'Long Haul',
      description: 'Complete a single session lasting an hour.',
      requirement: 'Complete one workout of at least 60 minutes.',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF4F46E5),
      points: 50,
      progressValue: _longestWorkout,
      target: 60,
      progressLabel: _longestWorkoutLabel,
    ),
    AchievementDefinition(
      id: 'weekend_warrior',
      category: AchievementCategory.challenges,
      title: 'Weekend Warrior',
      description: 'Make time for training on both weekend days.',
      requirement:
          'Complete a workout on Saturday and Sunday in the same week.',
      icon: Icons.celebration_rounded,
      color: Color(0xFF9333EA),
      points: 60,
      progressValue: _weekendDays,
      target: 2,
      progressLabel: _weekendLabel,
    ),
  ];

  static double _completedCount(AchievementProgress p) =>
      p.completedWorkouts.length.toDouble();
  static double _streakCount(AchievementProgress p) =>
      p.longestStreakDays.toDouble();
  static double _calorieCount(AchievementProgress p) =>
      p.completedCalories.toDouble();
  static double _minuteCount(AchievementProgress p) =>
      p.completedMinutes.toDouble();
  static double _longestWorkout(AchievementProgress p) =>
      p.longestWorkoutMinutes.toDouble();
  static double _weekendDays(AchievementProgress p) => p.weekendDays.toDouble();
  static String _completedCountLabel(AchievementProgress p) =>
      '${p.completedWorkouts.length} completed';
  static String _streakLabel(AchievementProgress p) =>
      '${p.longestStreakDays} consecutive days';
  static String _calorieLabel(AchievementProgress p) =>
      '${p.completedCalories} of 1,000 kcal';
  static String _minuteLabel(AchievementProgress p) =>
      '${p.completedMinutes} of 600 minutes';
  static String _longestWorkoutLabel(AchievementProgress p) =>
      '${p.longestWorkoutMinutes} of 60 minutes';
  static String _weekendLabel(AchievementProgress p) =>
      '${p.weekendDays} of 2 weekend days';

  static AchievementDefinition? byId(String id) {
    for (final definition in definitions) {
      if (definition.id == id) return definition;
    }
    return null;
  }
}
