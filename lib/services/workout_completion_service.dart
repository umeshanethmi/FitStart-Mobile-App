import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/services/achievement_service.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';

class WorkoutCompletionService {
  WorkoutCompletionService({
    DatabaseService? databaseService,
    AchievementService? achievementService,
  }) : _databaseService = databaseService ?? DatabaseService(),
       _achievementService = achievementService ?? AchievementService();

  final DatabaseService _databaseService;
  final AchievementService _achievementService;

  Future<String?> complete(WorkoutSession session) async {
    await _databaseService.saveCompletedWorkout(session);
    try {
      final workouts = await _databaseService.getWorkouts();
      await _achievementService.synchronize(workouts);
      return null;
    } catch (error) {
      return 'Workout saved, but achievements could not be updated. '
          'Open Achievements to retry. ($error)';
    }
  }
}
