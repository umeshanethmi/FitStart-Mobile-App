import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/exercise_detail_screen.dart';

class DailyWorkoutPlanScreen extends StatefulWidget {
  const DailyWorkoutPlanScreen({super.key});

  @override
  State<DailyWorkoutPlanScreen> createState() =>
      _DailyWorkoutPlanScreenState();
}

class _DailyWorkoutPlanScreenState extends State<DailyWorkoutPlanScreen> {
  static const Color _blue = Color(0xFF2563EB);
  final WorkoutPlan _plan = WorkoutPlan.beginnerSample;
  late final WorkoutSession _session;

  @override
  void initState() {
    super.initState();
    _session = WorkoutSession(plan: _plan);
  }

  void _openExercise(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          session: _session,
          exerciseIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(title: const Text('Daily Workout Plan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    _plan.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A simple, balanced session to help you build a routine.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _WorkoutTag(
                        icon: Icons.schedule_rounded,
                        label: '${_plan.durationMinutes} min',
                      ),
                      _WorkoutTag(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: _plan.difficulty,
                      ),
                      _WorkoutTag(
                        icon: Icons.fitness_center_rounded,
                        label: '${_plan.exercises.length} exercises',
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Your exercises',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < _plan.exercises.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExercisePlanCard(
                        number: index + 1,
                        name: _plan.exercises[index].name,
                        details: _plan.exercises[index].workDescription,
                        onTap: () => _openExercise(index),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => _openExercise(0),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Start Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(backgroundColor: _blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WorkoutTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade200),
    );
  }
}

class _ExercisePlanCard extends StatelessWidget {
  final int number;
  final String name;
  final String details;
  final VoidCallback onTap;

  const _ExercisePlanCard({
    required this.number,
    required this.name,
    required this.details,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEFF6FF),
          foregroundColor: const Color(0xFF2563EB),
          child: Text('$number'),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(details),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
