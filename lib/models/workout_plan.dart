class WorkoutPlan {
  final String id;
  final String title;
  final Map<String, dynamic> preferences;
  final List<Map<String, dynamic>> exercises;

  WorkoutPlan.fromMap(this.id, Map<String, dynamic> data)
    : title = data['title'] as String? ?? 'Workout Plan',
      preferences = Map<String, dynamic>.from(
        data['preferences'] as Map? ?? {},
      ),
      exercises = (data['exercises'] as List? ?? [])
          .map((exercise) => Map<String, dynamic>.from(exercise as Map))
          .toList();

  static String exerciseName(Map<String, dynamic> exercise) {
    return exercise['name'] as String? ??
        (exercise['exerciseId'] as String? ?? 'Exercise').replaceAll('_', ' ');
  }
}
