import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_session.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({super.key, required this.session});

  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final elapsed = session.elapsed;
    final elapsedSeconds = elapsed.inSeconds;
    final durationLabel = elapsed.inHours > 0
        ? '${elapsed.inHours}h ${elapsed.inMinutes.remainder(60)}m'
        : elapsed.inMinutes > 0
        ? '${elapsed.inMinutes}m ${elapsed.inSeconds.remainder(60)}s'
        : '${elapsed.inSeconds}s';
    final caloriesBurned = (elapsedSeconds * 5 / 60).round();
    final totalExercises = session.plan.exercises.length;
    final completedExercises = session.completedExerciseCount;
    final progress = totalExercises == 0
        ? 0.0
        : completedExercises / totalExercises;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Workout Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      _CompletionHeader(planName: session.plan.name),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              icon: Icons.schedule_rounded,
                              label: 'Duration',
                              value: durationLabel,
                              iconColor: _blue,
                              iconBackground: const Color(0xFFEFF6FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricCard(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Calories',
                              value: '~$caloriesBurned kcal',
                              caption: 'Estimated',
                              iconColor: const Color(0xFFEA580C),
                              iconBackground: const Color(0xFFFFF7ED),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ProgressCard(
                        progress: progress,
                        completedExercises: completedExercises,
                        totalExercises: totalExercises,
                        skippedExercises: session.skippedExerciseCount,
                        completedSets: session.completedSetCount,
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'You showed up, put in the work, and made progress. '
                        'That’s something to be proud of!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

class _CompletionHeader extends StatelessWidget {
  final String planName;

  const _CompletionHeader({required this.planName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFF2563EB),
            size: 48,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'SESSION COMPLETE',
            style: TextStyle(
              color: Color(0xFF15803D),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Workout completed!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Nice work completing $planName',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color iconColor;
  final Color iconBackground;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 3),
              Text(
                caption!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final int completedExercises;
  final int totalExercises;
  final int skippedExercises;
  final int completedSets;

  const _ProgressCard({
    required this.progress,
    required this.completedExercises,
    required this.totalExercises,
    required this.skippedExercises,
    required this.completedSets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout progress',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '$completedExercises of $totalExercises exercises',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE2E8F0),
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                _ProgressDetail(
                  icon: Icons.check_circle_rounded,
                  label: '$completedExercises completed',
                  color: const Color(0xFF16A34A),
                ),
                _ProgressDetail(
                  icon: Icons.skip_next_rounded,
                  label: '$skippedExercises skipped',
                  color: const Color(0xFF64748B),
                ),
                _ProgressDetail(
                  icon: Icons.repeat_rounded,
                  label: '$completedSets sets',
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ProgressDetail({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
