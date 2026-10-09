import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/active_workout_screen.dart';
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
  bool _isNavigatingAway = false;

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
        builder: (context) => WorkoutSummaryScreen(session: widget.session),
      ),
    );
  }

  void _backToActiveWorkout() {
    if (_isNavigatingAway) return;

    _isNavigatingAway = true;
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(
          session: widget.session,
          exerciseIndex: widget.completedExerciseIndex,
        ),
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
    final exercise =
        widget.session.plan.exercises[widget.completedExerciseIndex];
    final hasNextExercise =
        widget.completedExerciseIndex + 1 <
        widget.session.plan.exercises.length;
    final isRunning = _timer?.isActive ?? false;
    final restDuration = exercise.restSeconds;
    final timerProgress = restDuration > 0
        ? (_remainingSeconds / restDuration).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        title: const Text(
          'Recovery',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF3F8F7),
        foregroundColor: const Color(0xFF163B36),
        surfaceTintColor: const Color(0xFFF3F8F7),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 400 ? 18.0 : 24.0;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  21,
                                  24,
                                  21,
                                  22,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE5F4EF),
                                      Color(0xFFF1F8F4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(27),
                                  border: Border.all(
                                    color: const Color(0xFFD7EAE2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(19),
                                      ),
                                      child: const Icon(
                                        Icons.self_improvement_rounded,
                                        size: 31,
                                        color: Color(0xFF27806D),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Recovery Time',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF163B36),
                                        fontSize: 27,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      'Take a moment to reset after '
                                      '${exercise.name}.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF52736A),
                                        fontSize: 14,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: 244,
                                      height: 244,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 232,
                                            height: 232,
                                            child: CircularProgressIndicator(
                                              value: timerProgress,
                                              strokeWidth: 12,
                                              backgroundColor: const Color(
                                                0xFFCFE4DA,
                                              ),
                                              color: const Color(0xFF27806D),
                                              strokeCap: StrokeCap.round,
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _remainingSeconds == 0
                                                    ? 'REST COMPLETE'
                                                    : isRunning
                                                    ? 'BREATHE & RESET'
                                                    : 'TIME TO REST',
                                                style: const TextStyle(
                                                  color: Color(0xFF52736A),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _formattedTime,
                                                style: const TextStyle(
                                                  color: Color(0xFF163B36),
                                                  fontSize: 53,
                                                  height: 1.1,
                                                  fontWeight: FontWeight.w800,
                                                  fontFeatures: [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                isRunning
                                                    ? 'Timer running'
                                                    : _remainingSeconds == 0
                                                    ? 'Ready when you are'
                                                    : 'Pause and resume anytime',
                                                style: const TextStyle(
                                                  color: Color(0xFF648177),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 9,
                                      runSpacing: 9,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        _RecoveryPill(
                                          icon: Icons.water_drop_outlined,
                                          label: 'Take a sip of water',
                                        ),
                                        _RecoveryPill(
                                          icon: Icons.air_rounded,
                                          label: 'Slow your breathing',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                    color: const Color(0xFFE1ECE7),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF5F0),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.next_plan_rounded,
                                        color: Color(0xFF27806D),
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hasNextExercise
                                                ? 'Up next'
                                                : 'Final recovery',
                                            style: const TextStyle(
                                              color: Color(0xFF163B36),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            hasNextExercise
                                                ? widget
                                                      .session
                                                      .plan
                                                      .exercises[widget
                                                              .completedExerciseIndex +
                                                          1]
                                                      .name
                                                : 'Then wrap up your workout',
                                            style: const TextStyle(
                                              color: Color(0xFF52736A),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    13,
                    horizontalPadding,
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _remainingSeconds == 0
                                  ? null
                                  : _toggleTimer,
                              icon: Icon(
                                isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                isRunning
                                    ? 'Pause Timer'
                                    : _remainingSeconds == restDuration
                                    ? 'Start Timer'
                                    : 'Resume Timer',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF267363),
                                side: const BorderSide(
                                  color: Color(0xFFB7D9CC),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          if (_remainingSeconds == 0)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: _continueWorkout,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF27806D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  hasNextExercise
                                      ? 'Continue to Next Exercise'
                                      : 'View Workout Summary',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: TextButton(
                                onPressed: _continueWorkout,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF52736A),
                                ),
                                child: Text(
                                  hasNextExercise
                                      ? 'Skip Recovery'
                                      : 'Finish Recovery',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _isNavigatingAway
                                  ? null
                                  : _backToActiveWorkout,
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text(
                                'Back to Active Workout',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF163B36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecoveryPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RecoveryPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF27806D)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF35675C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
