class WorkoutPlanGenerator {
  static const goals = ['Lose Weight', 'Build Muscle', 'Stay Fit'];
  static const levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const equipmentOptions = ['None', 'Dumbbells', 'Gym'];
  static const durations = [20, 30, 45];

  Map<String, dynamic> generate({
    required String goal,
    String? planName,
    String experience = 'Beginner',
    String equipment = 'None',
    int daysPerWeek = 3,
    int durationMinutes = 30,
  }) {
    final title = planName?.trim() ?? '$goal Plan';
    if (title.isEmpty || title.length > 60) {
      throw ArgumentError(
        'Enter a workout plan name between 1 and 60 characters.',
      );
    }
    if (!goals.contains(goal) ||
        !levels.contains(experience) ||
        !equipmentOptions.contains(equipment) ||
        daysPerWeek < 1 ||
        daysPerWeek > 5 ||
        !durations.contains(durationMinutes)) {
      throw ArgumentError('Invalid workout preferences.');
    }

    final strength = switch (equipment) {
      'Dumbbells' => ['Goblet squat', 'Dumbbell floor press', 'Dumbbell row'],
      'Gym' => ['Leg press', 'Chest press machine', 'Seated cable row'],
      _ => ['Bodyweight squat', 'Wall push-up', 'Glute bridge'],
    };
    final cardio = experience == 'Beginner'
        ? ['Marching in place', 'Step touch']
        : ['Jumping jacks', 'High knees'];
    final names = switch (goal) {
      'Lose Weight' => [...cardio, strength[0], strength[1], 'Dead bug'],
      'Build Muscle' => [...strength, 'Calf raise', 'Dead bug'],
      _ => [strength[0], cardio[0], strength[1], 'Dead bug', 'Glute bridge'],
    };
    final sets = levels.indexOf(experience) + 2;
    final reps = goal == 'Build Muscle' ? 8 : 12;
    final rest = goal == 'Build Muscle' ? 90 : 60;
    final exerciseCount = switch (durationMinutes) {
      20 => 3,
      30 => 4,
      _ => 5,
    };

    return {
      'title': title,
      'isActive': true,
      'generationMethod': 'rule-based',
      'preferences': {
        'goal': goal,
        'experience': experience,
        'equipment': equipment,
        'daysPerWeek': daysPerWeek,
        'durationMinutes': durationMinutes,
      },
      'exercises': names
          .take(exerciseCount)
          .map(
            (name) => {
              'exerciseId': name.toLowerCase().replaceAll(
                RegExp(r'[^a-z0-9]+'),
                '_',
              ),
              'name': name,
              'sets': sets,
              'reps': reps,
              'restSeconds': rest,
            },
          )
          .toList(),
    };
  }
}
