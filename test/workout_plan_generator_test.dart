import 'package:flutter_test/flutter_test.dart';
import 'package:fitstart_mobile_app/services/workout_plan_generator.dart';

void main() {
  final generator = WorkoutPlanGenerator();

  test('no-equipment muscle plan uses bodyweight exercises', () {
    final plan = generator.generate(goal: 'Build Muscle');
    final exercises = plan['exercises'] as List;
    expect(exercises.first['name'], 'Bodyweight squat');
    expect(exercises.first['reps'], 8);
    expect(exercises.first['restSeconds'], 90);
    expect(plan['generationMethod'], 'rule-based');
  });

  test('equipment, experience and duration change the workout', () {
    final plan = generator.generate(
      goal: 'Build Muscle',
      equipment: 'Dumbbells',
      experience: 'Advanced',
      durationMinutes: 45,
      daysPerWeek: 4,
    );
    final exercises = plan['exercises'] as List;
    expect(exercises, hasLength(5));
    expect(exercises.first['name'], 'Goblet squat');
    expect(exercises.first['sets'], 4);
    expect((plan['preferences'] as Map)['daysPerWeek'], 4);
  });

  test('short beginner cardio plan avoids advanced cardio', () {
    final plan = generator.generate(goal: 'Lose Weight', durationMinutes: 20);
    final exercises = plan['exercises'] as List;
    expect(exercises, hasLength(3));
    expect(exercises.first['name'], 'Marching in place');
    expect(exercises.first['sets'], 2);
  });

  test('invalid preferences are rejected', () {
    expect(() => generator.generate(goal: 'Unknown'), throwsArgumentError);
    expect(
      () => generator.generate(goal: 'Stay Fit', daysPerWeek: 0),
      throwsArgumentError,
    );
    expect(
      () => generator.generate(goal: 'Stay Fit', durationMinutes: 0),
      throwsArgumentError,
    );
  });
}
