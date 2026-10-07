import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/exercise_detail_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_summary_screen.dart';

class RecoveryTimerScreen extends StatefulWidget {
  final WorkoutSession session;
  final int completedExerciseIndex;

  const RecoveryTimerScreen({
    super.key,
    required this.session,
    required this.completedExerciseIndex,
  });

  @override
  State<RecoveryTimerScreen> createState() => _RecoveryTimerScreenState();
}

class _RecoveryTimerScreenState extends State<RecoveryTimerScreen> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.session.plan.exercises[
      widget.completedExerciseIndex
    ].restSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      setState(() {});
      return;
    }

    if (_remainingSeconds == 0) return;

    setState(() {});
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _continueWorkout() {
    _timer?.cancel();
    final nextIndex = widget.completedExerciseIndex + 1;

    if (nextIndex < widget.session.plan.exercises.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseDetailScreen(
            session: widget.session,
            exerciseIndex: nextIndex,
          ),
        ),
      );
      return;
    }

    widget.session.finish();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutSummaryScreen(session: widget.session),
      ),
    );
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.session.plan.exercises[
      widget.completedExerciseIndex
    ];
    final hasNextExercise = widget.completedExerciseIndex + 1 <
        widget.session.plan.exercises.length;
    final isRunning = _timer?.isActive ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(title: const Text('Recovery')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.self_improvement_rounded,
                size: 66,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(height: 18),
              const Text(
                'Recovery Time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a breath after ${exercise.name}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 34),
              Text(
                _formattedTime,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 34),
              OutlinedButton.icon(
                onPressed: _remainingSeconds == 0 ? null : _toggleTimer,
                icon: Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(
                  isRunning
                      ? 'Pause Timer'
                      : _remainingSeconds == exercise.restSeconds
                          ? 'Start Timer'
                          : 'Resume Timer',
                ),
              ),
              const SizedBox(height: 12),
              if (_remainingSeconds == 0)
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: _continueWorkout,
                    child: Text(
                      hasNextExercise
                          ? 'Continue to Next Exercise'
                          : 'View Workout Summary',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _continueWorkout,
                  child: Text(
                    hasNextExercise ? 'Skip Recovery' : 'Finish Recovery',
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
