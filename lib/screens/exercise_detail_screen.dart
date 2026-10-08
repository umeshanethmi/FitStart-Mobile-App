import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/active_workout_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final WorkoutSession session;
  final int exerciseIndex;

  const ExerciseDetailScreen({
    super.key,
    required this.session,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = session.plan.exercises[exerciseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(title: const Text('Exercise Details')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    height: 210,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EDFE),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 62,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Exercise demonstration',
                          style: TextStyle(
                            color: Color(0xFF1E40AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exercise.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _DetailRow(label: 'Target area', value: exercise.targetArea),
                  _DetailRow(
                    label: 'Sets and reps',
                    value: exercise.workDescription,
                  ),
                  _DetailRow(
                    label: 'Rest between sets',
                    value: '${exercise.restSeconds} seconds',
                  ),
                  const SizedBox(height: 18),
                  if (exercise.beginnerTip.isNotEmpty)
                    Card(
                      color: const Color(0xFFEFF6FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exercise.beginnerTip,
                                style: const TextStyle(height: 1.4),
                              ),
                            ),
                          ],
                        ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveWorkoutScreen(
                          session: session,
                          exerciseIndex: exerciseIndex,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Start Exercise',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
