import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/recovery_timer_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutSession session;
  final int exerciseIndex;

  const ActiveWorkoutScreen({
    super.key,
    required this.session,
    required this.exerciseIndex,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    widget.session.start();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.session.plan.exercises[widget.exerciseIndex];
    final completedSets = widget.session.completedSetsFor(widget.exerciseIndex);
    final currentSet = (completedSets + 1).clamp(1, exercise.sets);
    final isLastSet = currentSet == exercise.sets;
    final progress = completedSets / exercise.sets;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(title: const Text('Active Workout')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              exercise.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Exercise ${widget.exerciseIndex + 1} of '
              '${widget.session.plan.exercises.length}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 228,
                height: 228,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 13,
                        backgroundColor: const Color(0xFFDCE7F8),
                        color: const Color(0xFF2563EB),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SET $currentSet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${exercise.sets}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'total sets',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              exercise.activeDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            if (_isPaused) ...[
              const SizedBox(height: 10),
              const Text(
                'Workout paused',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => setState(() => _isPaused = !_isPaused),
              icon: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
              label: Text(_isPaused ? 'Resume' : 'Pause'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _isPaused
                    ? null
                    : () {
                        widget.session.completeSet(widget.exerciseIndex);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecoveryTimerScreen(
                              session: widget.session,
                              completedExerciseIndex: widget.exerciseIndex,
                            ),
                          ),
                        );
                      },
                child: Text(
                  isLastSet ? 'Finish Exercise' : 'Complete Set',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
