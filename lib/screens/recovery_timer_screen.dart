import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/exercise_detail_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_summary_screen.dart';
import 'package:fitstart_mobile_app/screens/active_workout_screen.dart';

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
  DateTime? _timerDeadline;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget
        .session
        .plan
        .exercises[widget.completedExerciseIndex]
        .restSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      final deadline = _timerDeadline;
      if (deadline != null) {
        final remaining = deadline.difference(DateTime.now()).inMilliseconds;
        _remainingSeconds = (remaining / 1000).ceil().clamp(0, 1 << 30);
      }
      _timerDeadline = null;
      setState(() {});
      return;
    }

    if (_remainingSeconds == 0) return;

    _timerDeadline = DateTime.now().add(Duration(seconds: _remainingSeconds));
    setState(() {});
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final deadline = _timerDeadline;
      if (deadline == null) {
        timer.cancel();
        return;
      }
      final remaining = deadline.difference(DateTime.now()).inMilliseconds;
      final secondsRemaining = (remaining / 1000).ceil().clamp(0, 1 << 30);
      if (secondsRemaining == 0) {
        timer.cancel();
        _timerDeadline = null;
      }
      if (mounted) setState(() => _remainingSeconds = secondsRemaining);
    });
  }

  void _continueWorkout() {
    _timer?.cancel();
    _timerDeadline = null;
    if (!widget.session.isExerciseComplete(widget.completedExerciseIndex)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreen(
            session: widget.session,
            exerciseIndex: widget.completedExerciseIndex,
          ),
        ),
      );
      return;
    }
    final nextIndex = _nextExerciseIndex;

    if (nextIndex != null) {
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

    _finishWorkout();
  }

  Future<void> _finishWorkout() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    widget.session.finish();
    final wasSaved = widget.session.onCompleted != null;
    String? completionWarning;
    try {
      completionWarning = await widget.session.onCompleted?.call(
        widget.session,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFinishing = false);
      final message = error is FirebaseException
          ? 'Could not save your completed workout (${error.code}): '
                '${error.message ?? 'Check your connection and access rules.'}'
          : 'Could not save your completed workout: $error';
      _showMessage(message);
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(
          session: widget.session,
          progressSaved: wasSaved,
          completionWarning: completionWarning,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  int? get _nextExerciseIndex {
    for (var index = 0; index < widget.session.plan.exercises.length; index++) {
      if (!widget.session.isExerciseComplete(index)) return index;
    }
    return null;
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final exercise =
        widget.session.plan.exercises[widget.completedExerciseIndex];
    final hasNextSet = !widget.session.isExerciseComplete(
      widget.completedExerciseIndex,
    );
    final hasNextExercise = _nextExerciseIndex != null;
    final isRunning = _timer?.isActive ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(title: const Text('Recovery')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
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
                  onPressed: _isFinishing ? null : _continueWorkout,
                  child: Text(
                    _isFinishing
                        ? 'Saving workout...'
                        : hasNextSet
                        ? 'Continue to Next Set'
                        : hasNextExercise
                        ? 'Continue to Next Exercise'
                        : 'View Workout Summary',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _isFinishing ? null : _continueWorkout,
                child: Text(
                  _isFinishing
                      ? 'Saving workout...'
                      : hasNextExercise
                      ? 'Skip Recovery'
                      : 'Finish Recovery',
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
