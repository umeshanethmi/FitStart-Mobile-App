import 'package:flutter/material.dart';

class ProgressData {
  const ProgressData._();

  static const int workoutGoal = 5;
  static const int weeklyCalorieGoal = 2250;
  static const int fallbackWorkoutDurationMinutes = 30;
  static const int estimatedCaloriesPerMinute = 6;
  static const List<String> dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static DateTime currentWeekStart() => _weekStartFor(DateTime.now());

  static int estimatedCaloriesForSeconds(int seconds) {
    if (seconds <= 0) return 0;
    return (seconds * estimatedCaloriesPerMinute / 60).round().clamp(
      1,
      1 << 30,
    );
  }

  static String durationLabel(int seconds) {
    if (seconds <= 0) return '0 sec';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    if (hours > 0) {
      return remainingSeconds == 0
          ? '${hours}h ${minutes}m'
          : '${hours}h ${minutes}m ${remainingSeconds}s';
    }
    if (minutes > 0) {
      return remainingSeconds == 0
          ? '$minutes min'
          : '$minutes min $remainingSeconds sec';
    }
    return '$seconds sec';
  }

  static DateTime _weekStartFor(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static DateTime _sampleDateForDay(int dayIndex) =>
      currentWeekStart().add(Duration(days: dayIndex, hours: 12));

  static final List<WorkoutSession> sampleWorkouts = [
    WorkoutSession(
      id: 'full_body_strength',
      name: 'Full Body Strength',
      date: 'Sunday',
      dayIndex: 6,
      weekStart: currentWeekStart(),
      completedAt: _sampleDateForDay(6),
      durationMinutes: 60,
      calories: 740,
      iconCodePoint: Icons.fitness_center_rounded.codePoint,
      colorValue: const Color(0xFF2563EB).toARGB32(),
      status: WorkoutStatus.completed,
      exerciseSummary: [
        WorkoutExercise(
          id: 'squats',
          name: 'Squats',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'push_ups',
          name: 'Push-ups',
          sets: 3,
          reps: 10,
          restSeconds: 45,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'dumbbell_rows',
          name: 'Dumbbell rows',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'plank',
          name: 'Plank',
          sets: 3,
          reps: 1,
          repsLabel: '45 sec',
          restSeconds: 45,
          isCompleted: true,
        ),
      ],
    ),
    WorkoutSession(
      id: 'cardio_session',
      name: 'Cardio Session',
      date: 'Saturday',
      dayIndex: 5,
      weekStart: currentWeekStart(),
      completedAt: _sampleDateForDay(5),
      durationMinutes: 48,
      calories: 500,
      iconCodePoint: Icons.directions_run_rounded.codePoint,
      colorValue: const Color(0xFFF59E0B).toARGB32(),
      status: WorkoutStatus.completed,
      exerciseSummary: [
        WorkoutExercise(
          id: 'brisk_intervals',
          name: 'Brisk intervals',
          sets: 5,
          reps: 1,
          repsLabel: '2 min',
          restSeconds: 60,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'jump_rope',
          name: 'Jump rope',
          sets: 3,
          reps: 60,
          restSeconds: 45,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'cool_down_walk',
          name: 'Cool-down walk',
          sets: 1,
          reps: 1,
          repsLabel: '5 min',
          restSeconds: 0,
          isCompleted: true,
        ),
      ],
    ),
    WorkoutSession(
      id: 'morning_yoga',
      name: 'Morning Yoga',
      date: 'Thursday',
      dayIndex: 3,
      weekStart: currentWeekStart(),
      completedAt: _sampleDateForDay(3),
      durationMinutes: 30,
      calories: 280,
      iconCodePoint: Icons.self_improvement_rounded.codePoint,
      colorValue: const Color(0xFF7C3AED).toARGB32(),
      status: WorkoutStatus.completed,
      exerciseSummary: [
        WorkoutExercise(
          id: 'sun_salutations',
          name: 'Sun salutations',
          sets: 3,
          reps: 5,
          restSeconds: 30,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'warrior_flow',
          name: 'Warrior flow',
          sets: 3,
          reps: 1,
          repsLabel: '1 min',
          restSeconds: 30,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'breathing_exercises',
          name: 'Breathing exercises',
          sets: 1,
          reps: 1,
          repsLabel: '5 min',
          restSeconds: 0,
          isCompleted: true,
        ),
      ],
    ),
    WorkoutSession(
      id: 'strength_mobility',
      name: 'Strength & Mobility',
      date: 'Tuesday',
      dayIndex: 1,
      weekStart: currentWeekStart(),
      completedAt: _sampleDateForDay(1),
      durationMinutes: 67,
      calories: 320,
      iconCodePoint: Icons.accessibility_new_rounded.codePoint,
      colorValue: const Color(0xFF0D9488).toARGB32(),
      status: WorkoutStatus.completed,
      exerciseSummary: [
        WorkoutExercise(
          id: 'mobility_flow',
          name: 'Mobility flow',
          sets: 2,
          reps: 8,
          restSeconds: 30,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'bodyweight_strength',
          name: 'Bodyweight strength',
          sets: 3,
          reps: 10,
          restSeconds: 45,
          isCompleted: true,
        ),
        WorkoutExercise(
          id: 'stretching',
          name: 'Stretching',
          sets: 1,
          reps: 1,
          repsLabel: '5 min',
          restSeconds: 0,
          isCompleted: true,
        ),
      ],
    ),
    WorkoutSession(
      id: 'recovery_walk',
      name: 'Recovery Walk',
      date: 'Monday',
      dayIndex: 0,
      weekStart: currentWeekStart(),
      durationMinutes: 0,
      calories: 0,
      iconCodePoint: Icons.directions_walk_rounded.codePoint,
      colorValue: const Color(0xFF64748B).toARGB32(),
      status: WorkoutStatus.planned,
      exerciseSummary: [
        WorkoutExercise(
          id: 'low_impact_walk',
          name: 'Low-impact walk',
          sets: 1,
          reps: 1,
          repsLabel: '20 min',
          restSeconds: 0,
        ),
        WorkoutExercise(
          id: 'gentle_cool_down',
          name: 'Gentle cool-down',
          sets: 1,
          reps: 1,
          repsLabel: '5 min',
          restSeconds: 0,
        ),
      ],
    ),
  ];
}

enum WorkoutStatus { planned, inProgress, completed, cancelled }

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.name,
    required this.date,
    required this.dayIndex,
    this.weekStart,
    this.completedAt,
    required this.durationMinutes,
    int? durationSeconds,
    required this.calories,
    required this.iconCodePoint,
    required this.colorValue,
    required this.status,
    required this.exerciseSummary,
    this.notes = '',
    this.rating = 0,
    this.startedAt,
    this.createdAt,
    this.updatedAt,
    this.sortOrder = 0,
  }) : durationSeconds = durationSeconds ?? durationMinutes * 60;

  final String id;
  final String name;
  final String date;
  final int dayIndex;
  final DateTime? weekStart;
  final DateTime? completedAt;
  final int durationMinutes;
  final int durationSeconds;
  final int calories;
  final int iconCodePoint;
  final int colorValue;
  final WorkoutStatus status;
  final List<WorkoutExercise> exerciseSummary;
  final String notes;
  final int rating;
  final DateTime? startedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sortOrder;

  bool get isCompleted => status == WorkoutStatus.completed;
  bool get isStarted => status == WorkoutStatus.inProgress;
  bool get isPlanned => status == WorkoutStatus.planned;
  bool get isCancelled => status == WorkoutStatus.cancelled;
  String get displayDate {
    final completion = isCompleted ? completedAt : null;
    if (completion == null) return date;
    final month = completion.month.toString().padLeft(2, '0');
    final day = completion.day.toString().padLeft(2, '0');
    return '${completion.year}-$month-$day';
  }

  IconData get icon {
    if (iconCodePoint == Icons.directions_run_rounded.codePoint) {
      return Icons.directions_run_rounded;
    }
    if (iconCodePoint == Icons.self_improvement_rounded.codePoint) {
      return Icons.self_improvement_rounded;
    }
    if (iconCodePoint == Icons.accessibility_new_rounded.codePoint) {
      return Icons.accessibility_new_rounded;
    }
    if (iconCodePoint == Icons.directions_walk_rounded.codePoint) {
      return Icons.directions_walk_rounded;
    }
    return Icons.fitness_center_rounded;
  }

  Color get color => Color(colorValue);

  WorkoutSession copyWith({
    String? name,
    String? date,
    int? dayIndex,
    DateTime? weekStart,
    DateTime? completedAt,
    int? durationMinutes,
    int? durationSeconds,
    int? calories,
    int? iconCodePoint,
    int? colorValue,
    WorkoutStatus? status,
    List<WorkoutExercise>? exerciseSummary,
    String? notes,
    int? rating,
    DateTime? startedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return WorkoutSession(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      dayIndex: dayIndex ?? this.dayIndex,
      weekStart: weekStart ?? this.weekStart,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds:
          durationSeconds ??
          (durationMinutes == null
              ? this.durationSeconds
              : durationMinutes * 60),
      calories: calories ?? this.calories,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      status: status ?? this.status,
      exerciseSummary: exerciseSummary ?? this.exerciseSummary,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      startedAt: startedAt ?? this.startedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'date': date,
    'dayIndex': dayIndex,
    'weekStart': weekStart,
    'completedAt': completedAt,
    'durationMinutes': durationMinutes,
    'durationSeconds': durationSeconds,
    'calories': calories,
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'status': status.name,
    'exercises': exerciseSummary.map((exercise) => exercise.toMap()).toList(),
    'notes': notes,
    'rating': rating,
    'startedAt': startedAt,
    'sortOrder': sortOrder,
  };

  factory WorkoutSession.fromMap(String id, Map<String, dynamic> map) {
    final rawExercises = map['exercises'];
    final exercises = rawExercises is List
        ? rawExercises
              .whereType<Map>()
              .map(
                (exercise) => WorkoutExercise.fromMap(
                  Map<String, dynamic>.from(exercise),
                ),
              )
              .toList()
        : <WorkoutExercise>[];
    final statusName = _asString(map['status'], fallback: 'planned');
    final status = WorkoutStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => map['isCompleted'] == true
          ? WorkoutStatus.completed
          : WorkoutStatus.planned,
    );
    final startedAtValue = map['startedAt'];
    final createdAtValue = map['createdAt'];
    final updatedAtValue = map['updatedAt'];
    final createdAt = _asDateTime(createdAtValue);
    final weekStartValue =
        map['weekStart'] ??
        createdAt ??
        (status == WorkoutStatus.planned
            ? ProgressData.currentWeekStart()
            : null);
    final completedAtValue = map['completedAt'];
    final dateValue = _asString(map['date']);
    final dayIndex = _asInt(
      map['dayIndex'],
      fallback: (createdAt?.weekday ?? 1) - 1,
    ).clamp(0, 6).toInt();
    final durationSeconds = _asInt(
      map['durationSeconds'],
      fallback: _asInt(map['durationMinutes']) * 60,
    ).clamp(0, 1 << 30).toInt();
    final recordedCalories = _asInt(map['calories']);
    final calories = recordedCalories > 0 || durationSeconds == 0
        ? recordedCalories.clamp(0, 1 << 30).toInt()
        : ProgressData.estimatedCaloriesForSeconds(durationSeconds);

    return WorkoutSession(
      id: id,
      name: _asString(
        map['name'],
        fallback: _asString(map['title'], fallback: 'Workout'),
      ),
      date: dateValue.isEmpty ? ProgressData.dayLabels[dayIndex] : dateValue,
      dayIndex: dayIndex,
      weekStart: _asDateTime(weekStartValue),
      completedAt:
          _asDateTime(completedAtValue) ??
          (status == WorkoutStatus.completed ? createdAt : null),
      durationMinutes: _asInt(map['durationMinutes']).clamp(0, 1 << 30).toInt(),
      durationSeconds: durationSeconds,
      calories: calories,
      iconCodePoint: _asInt(map['iconCodePoint'], fallback: 0),
      colorValue: _asInt(map['colorValue'], fallback: 0xFF2563EB),
      status: status,
      exerciseSummary: exercises,
      notes: _asString(map['notes']),
      rating: _asInt(map['rating']).clamp(0, 5).toInt(),
      startedAt: _asDateTime(startedAtValue),
      createdAt: createdAt,
      updatedAt: _asDateTime(updatedAtValue),
      sortOrder: _asInt(map['sortOrder']),
    );
  }

  static String _asString(Object? value, {String fallback = ''}) =>
      value is String ? value : fallback;

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.repsLabel,
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? repsLabel;
  final bool isCompleted;

  WorkoutExercise copyWith({bool? isCompleted}) => WorkoutExercise(
    id: id,
    name: name,
    sets: sets,
    reps: reps,
    restSeconds: restSeconds,
    repsLabel: repsLabel,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
    'repsLabel': repsLabel,
    'isCompleted': isCompleted,
  };

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    final rawId = WorkoutSession._asString(
      map['id'],
      fallback: WorkoutSession._asString(map['exerciseId']),
    );
    final rawName = WorkoutSession._asString(
      map['name'],
      fallback: WorkoutSession._asString(
        map['exerciseId'],
        fallback: 'Exercise',
      ),
    );
    final name = rawName
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
    return WorkoutExercise(
      id: rawId,
      name: name,
      sets: WorkoutSession._asInt(map['sets']),
      reps: WorkoutSession._asInt(map['reps']),
      restSeconds: WorkoutSession._asInt(map['restSeconds']),
      repsLabel: WorkoutSession._asString(map['repsLabel']).isEmpty
          ? null
          : WorkoutSession._asString(map['repsLabel']),
      isCompleted: map['isCompleted'] == true,
    );
  }
}

class ProgressMetrics {
  ProgressMetrics(Iterable<WorkoutSession> sessions) {
    final uniqueWorkouts = <String, WorkoutSession>{};
    for (final workout in sessions) {
      uniqueWorkouts[workout.id] = workout;
    }
    workouts = uniqueWorkouts.values.toList(growable: false);
    final weekStart = ProgressData.currentWeekStart();
    bool belongsToCurrentWeek(WorkoutSession workout) {
      final activityDate = workout.isCompleted
          ? workout.completedAt ??
                workout.startedAt ??
                workout.createdAt ??
                workout.weekStart
          : workout.weekStart ?? workout.createdAt;
      return activityDate == null ||
          ProgressData._weekStartFor(activityDate) == weekStart;
    }

    currentWeekWorkouts = workouts.where(belongsToCurrentWeek).toList();
    completed = currentWeekWorkouts
        .where((workout) => workout.isCompleted)
        .toList();
    planned = workouts
        .where((workout) => belongsToCurrentWeek(workout) && workout.isPlanned)
        .toList();
    completedCount = completed.length;
    totalDurationSeconds = completed.fold(
      0,
      (sum, workout) => sum + workout.durationSeconds,
    );
    totalCalories = completed.fold(0, (sum, workout) => sum + workout.calories);
    dailyActiveSeconds = List<int>.filled(7, 0);
    dailyCalories = List<int>.filled(7, 0);
    for (final workout in completed) {
      final completionDate =
          workout.completedAt ?? workout.startedAt ?? workout.createdAt;
      final day = ((completionDate?.weekday ?? workout.dayIndex + 1) - 1)
          .clamp(0, 6)
          .toInt();
      dailyActiveSeconds[day] += workout.durationSeconds;
      dailyCalories[day] += workout.calories;
    }
    dailyActiveMinutes = dailyActiveSeconds
        .map((seconds) => (seconds / 60).ceil())
        .toList(growable: false);
    historyCompleted = workouts.where((workout) => workout.isCompleted).toList()
      ..sort((first, second) {
        final firstDate =
            first.completedAt ?? first.startedAt ?? first.createdAt;
        final secondDate =
            second.completedAt ?? second.startedAt ?? second.createdAt;
        if (firstDate == null) return 1;
        if (secondDate == null) return -1;
        return secondDate.compareTo(firstDate);
      });
    historyDurationSeconds = historyCompleted.fold(
      0,
      (sum, workout) => sum + workout.durationSeconds,
    );
    historyCalories = historyCompleted.fold(
      0,
      (sum, workout) => sum + workout.calories,
    );
    final previousWeek = weekStart.subtract(const Duration(days: 7));
    final previousWeekRecords = historyCompleted.where((workout) {
      final completedOn =
          workout.completedAt ?? workout.startedAt ?? workout.createdAt;
      return completedOn != null &&
          ProgressData._weekStartFor(completedOn) == previousWeek;
    });
    hasPreviousWeekData = previousWeekRecords.isNotEmpty;
    previousWeekActiveSeconds = previousWeekRecords.fold(
      0,
      (sum, workout) => sum + workout.durationSeconds,
    );
    previousWeekActiveMinutes = previousWeekActiveSeconds ~/ 60;
    totalDurationMinutes = totalDurationSeconds ~/ 60;
    historyDurationMinutes = historyDurationSeconds ~/ 60;
    final now = DateTime.now();
    final currentMonthWorkouts = historyCompleted.where((workout) {
      final completedOn =
          workout.completedAt ?? workout.startedAt ?? workout.createdAt;
      return completedOn != null &&
          completedOn.year == now.year &&
          completedOn.month == now.month;
    });
    monthlyCompletedCount = currentMonthWorkouts.length;
    monthlyDurationSeconds = currentMonthWorkouts.fold(
      0,
      (sum, workout) => sum + workout.durationSeconds,
    );
    monthlyCalories = currentMonthWorkouts.fold(
      0,
      (sum, workout) => sum + workout.calories,
    );
  }

  late final List<WorkoutSession> workouts;
  late final List<WorkoutSession> currentWeekWorkouts;
  late final List<WorkoutSession> completed;
  late final List<WorkoutSession> planned;
  late final List<WorkoutSession> historyCompleted;
  late final int completedCount;
  late final int totalDurationSeconds;
  late final int totalDurationMinutes;
  late final int totalCalories;
  late final int historyDurationSeconds;
  late final int historyDurationMinutes;
  late final int historyCalories;
  late final int previousWeekActiveSeconds;
  late final int previousWeekActiveMinutes;
  late final bool hasPreviousWeekData;
  late final List<int> dailyActiveSeconds;
  late final List<int> dailyActiveMinutes;
  late final List<int> dailyCalories;
  late final int monthlyCompletedCount;
  late final int monthlyDurationSeconds;
  late final int monthlyCalories;

  int get workoutCompletionPercent => ProgressData.workoutGoal == 0
      ? 0
      : (completedCount * 100 / ProgressData.workoutGoal)
            .round()
            .clamp(0, 100)
            .toInt();
  int get totalWorkoutCount =>
      workouts.where((workout) => !workout.isCancelled).length;
  int get historyCompletedCount => historyCompleted.length;
  int get averageWorkoutMinutes => completedCount == 0
      ? 0
      : (totalDurationSeconds / completedCount / 60).round();
  int get calorieGoalPercent => ProgressData.weeklyCalorieGoal == 0
      ? 0
      : (totalCalories * 100 / ProgressData.weeklyCalorieGoal).round();
  int get mostActiveDayIndex => _maxIndex(dailyActiveMinutes);
  int get highestCalorieDayIndex => _maxIndex(dailyCalories);
  int get currentStreak {
    final activeDays = [
      for (var index = 0; index < dailyActiveMinutes.length; index++)
        if (dailyActiveMinutes[index] > 0) index,
    ];
    if (activeDays.isEmpty) return 0;
    var streak = 1;
    for (var index = activeDays.length - 1; index > 0; index--) {
      if (activeDays[index] - activeDays[index - 1] != 1) break;
      streak++;
    }
    return streak;
  }

  int _maxIndex(List<int> values) {
    if (values.isEmpty) return 0;
    var index = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[index]) index = i;
    }
    return index;
  }
}
