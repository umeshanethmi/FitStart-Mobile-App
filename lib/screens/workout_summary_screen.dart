import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final elapsedMinutes = session.elapsed.inMinutes;
    final durationLabel = elapsedMinutes == 0
        ? 'Less than 1 min'
        : '$elapsedMinutes min';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Workout Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.check_circle_rounded,
              size: 76,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(height: 18),
            const Text(
              'Workout completed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.plan.name,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 28),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Duration',
                      value: durationLabel,
                      icon: Icons.schedule_rounded,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Exercises completed',
                      value:
                          '${session.completedExerciseCount} / '
                          '${session.plan.exercises.length}',
                      icon: Icons.fitness_center_rounded,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Sets completed',
                      value: '${session.completedSetCount}',
                      icon: Icons.repeat_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Great job showing up for yourself. Every workout is a step '
              'forward!',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
