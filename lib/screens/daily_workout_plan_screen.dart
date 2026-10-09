import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/exercise_detail_screen.dart';

class DailyWorkoutPlanScreen extends StatefulWidget {
  const DailyWorkoutPlanScreen({super.key});

  @override
  State<DailyWorkoutPlanScreen> createState() => _DailyWorkoutPlanScreenState();
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
        builder: (context) =>
            ExerciseDetailScreen(session: _session, exerciseIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text(
          'Workout Plan',
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
                      10,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PlanHero(
                                name: _plan.name,
                                duration: _plan.durationMinutes,
                                difficulty: _plan.difficulty,
                                exerciseCount: _plan.exercises.length,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Workout flow',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_plan.exercises.length} movements',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Follow the sequence at your own pace.',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              for (
                                var index = 0;
                                index < _plan.exercises.length;
                                index++
                              )
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ExercisePlanCard(
                                    number: index + 1,
                                    isLast: index == _plan.exercises.length - 1,
                                    name: _plan.exercises[index].name,
                                    targetArea:
                                        _plan.exercises[index].targetArea,
                                    details:
                                        _plan.exercises[index].workDescription,
                                    onTap: () => _openExercise(index),
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
                    14,
                    horizontalPadding,
                    18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => _openExercise(0),
                          icon: const Icon(Icons.play_arrow_rounded, size: 23),
                          label: const Text(
                            'Start Workout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
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

class _PlanHero extends StatelessWidget {
  final String name;
  final int duration;
  final String difficulty;
  final int exerciseCount;

  const _PlanHero({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.exerciseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE7ECF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A simple, balanced session to help you build a routine.',
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _WorkoutTag(icon: Icons.schedule_rounded, label: '$duration min'),
              _WorkoutTag(
                icon: Icons.signal_cellular_alt_rounded,
                label: difficulty,
              ),
              _WorkoutTag(
                icon: Icons.fitness_center_rounded,
                label: '$exerciseCount exercises',
              ),
            ],
          ),
          const SizedBox(height: 21),
          Row(
            children: List.generate(
              exerciseCount * 2 - 1,
              (index) => Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index == exerciseCount * 2 - 2 ? 0 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? const Color(0xFFBFDBFE)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A guided $exerciseCount-step session',
            style: TextStyle(
              color: Colors.blueGrey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExercisePlanCard extends StatelessWidget {
  final int number;
  final bool isLast;
  final String name;
  final String targetArea;
  final String details;
  final VoidCallback onTap;

  const _ExercisePlanCard({
    required this.number,
    required this.isLast,
    required this.name,
    required this.targetArea,
    required this.details,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE7ECF4)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Column(
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        number.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 12,
                        margin: const EdgeInsets.only(top: 5),
                        color: const Color(0xFFDBEAFE),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      targetArea,
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FD),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        details,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF94A3B8),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
