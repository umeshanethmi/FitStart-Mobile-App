import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/exercise_detail_screen.dart';
import 'package:fitstart_mobile_app/screens/recovery_timer_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_summary_screen.dart';

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
  bool _isSkipping = false;
  bool _isAdvancing = false;
  bool _isEnding = false;
  bool _savingSummary = false;

  @override
  void initState() {
    super.initState();
    widget.session.start();
  }

  Future<void> _showSummary() async {
    if (_savingSummary) return;
    setState(() => _savingSummary = true);
    widget.session.finish();
    final isComplete =
        widget.session.completedExerciseCount ==
        widget.session.plan.exercises.length;
    final shouldSave = isComplete && widget.session.onCompleted != null;
    String? warning;
    try {
      if (shouldSave) {
        warning = await widget.session.onCompleted!(widget.session);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isEnding = false;
        _isSkipping = false;
        _isAdvancing = false;
        _savingSummary = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save your completed workout: $error'),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(
          session: widget.session,
          progressSaved: shouldSave,
          completionWarning: warning,
        ),
      ),
    );
  }

  void _skipExercise() {
    if (_isSkipping) return;

    _isSkipping = true;
    widget.session.skipExercise(widget.exerciseIndex);
    final nextIndex = widget.session.nextPendingExerciseIndex;

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

    _showSummary();
  }

  void _advanceToNextExercise() {
    if (_isAdvancing) return;

    _isAdvancing = true;
    final nextIndex = widget.session.nextPendingExerciseIndex;

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

    _showSummary();
  }

  void _endWorkout() {
    if (_isEnding) return;

    _isEnding = true;
    _showSummary();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.session.plan.exercises[widget.exerciseIndex];
    final completedSets = widget.session.completedSetsFor(widget.exerciseIndex);
    final currentSet = (completedSets + 1).clamp(1, exercise.sets);
    final isLastSet = currentSet == exercise.sets;
    final isExerciseComplete = widget.session.isExerciseComplete(
      widget.exerciseIndex,
    );
    final setProgress = completedSets / exercise.sets;
    final exerciseCount = widget.session.plan.exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text(
          'Active Workout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: const Color(0xFFF6F8FD),
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
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'YOUR WORKOUT',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${widget.exerciseIndex + 1} / $exerciseCount',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value:
                                      (widget.exerciseIndex + 1) /
                                      exerciseCount,
                                  minHeight: 7,
                                  backgroundColor: const Color(0xFFDBEAFE),
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  21,
                                  20,
                                  24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: const Color(0xFFE7ECF4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A)
                                          .withValues(alpha: 0.035),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isPaused
                                            ? const Color(0xFFFFF7ED)
                                            : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isPaused
                                                ? Icons
                                                      .pause_circle_filled_rounded
                                                : Icons.bolt_rounded,
                                            size: 16,
                                            color: _isPaused
                                                ? const Color(0xFFEA580C)
                                                : const Color(0xFF2563EB),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _isPaused
                                                ? 'WORKOUT PAUSED'
                                                : 'NOW IN PROGRESS',
                                            style: TextStyle(
                                              color: _isPaused
                                                  ? const Color(0xFFC2410C)
                                                  : const Color(0xFF1D4ED8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      exercise.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 27,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      exercise.targetArea,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: 218,
                                      height: 218,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 208,
                                            height: 208,
                                            child: CircularProgressIndicator(
                                              value: setProgress,
                                              strokeWidth: 13,
                                              backgroundColor: const Color(
                                                0xFFE7EFFB,
                                              ),
                                              color: const Color(0xFF2563EB),
                                              strokeCap: StrokeCap.round,
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'SET $currentSet',
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$currentSet',
                                                style: const TextStyle(
                                                  color: Color(0xFF0F172A),
                                                  fontSize: 60,
                                                  height: 1.05,
                                                  fontWeight: FontWeight.w800,
                                                  fontFeatures: [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                'of ${exercise.sets} sets',
                                                style: TextStyle(
                                                  color:
                                                      Colors.blueGrey.shade600,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F8FD),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.menu_book_rounded,
                                            size: 19,
                                            color: Color(0xFF2563EB),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Movement cue',
                                                  style: TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  exercise.activeDescription,
                                                  style: TextStyle(
                                                    color: Colors
                                                        .blueGrey
                                                        .shade700,
                                                    fontSize: 13,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        _WorkoutInfoChip(
                                          icon: Icons.repeat_rounded,
                                          text: exercise.workDescription,
                                        ),
                                        _WorkoutInfoChip(
                                          icon: Icons.hourglass_bottom_rounded,
                                          text: '${exercise.restSeconds}s rest',
                                        ),
                                      ],
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
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _savingSummary
                                      ? null
                                      : () => setState(
                                          () => _isPaused = !_isPaused,
                                        ),
                                  icon: Icon(
                                    _isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                  ),
                                  label: Text(_isPaused ? 'Resume' : 'Pause'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1D4ED8),
                                    side: const BorderSide(
                                      color: Color(0xFFBFDBFE),
                                    ),
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _savingSummary
                                      ? null
                                      : isExerciseComplete
                                      ? (_isAdvancing
                                            ? null
                                            : _advanceToNextExercise)
                                      : (_isSkipping ? null : _skipExercise),
                                  icon: Icon(
                                    isExerciseComplete
                                        ? Icons.arrow_forward_rounded
                                        : Icons.skip_next_rounded,
                                  ),
                                  label: Text(
                                    isExerciseComplete
                                        ? 'Next Workout'
                                        : 'Skip Workout',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: FilledButton(
                                    onPressed:
                                        _isPaused ||
                                            isExerciseComplete ||
                                            _savingSummary
                                        ? null
                                        : () {
                                            widget.session.completeSet(
                                              widget.exerciseIndex,
                                            );
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecoveryTimerScreen(
                                                      session: widget.session,
                                                      completedExerciseIndex:
                                                          widget.exerciseIndex,
                                                    ),
                                              ),
                                            );
                                          },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      isLastSet
                                          ? 'Finish Exercise'
                                          : 'Complete Set',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _isEnding || _savingSummary
                                    ? null
                                    : _endWorkout,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFB91C1C),
                                  side: const BorderSide(
                                    color: Color(0xFFFECACA),
                                  ),
                                  minimumSize: const Size(0, 54),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'End Workout',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
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

class _WorkoutInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WorkoutInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1E40AF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
