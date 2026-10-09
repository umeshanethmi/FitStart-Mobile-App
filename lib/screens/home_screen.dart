import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';
import 'package:fitstart_mobile_app/screens/daily_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _navy = Color(0xFF0F172A);
  static const Color _background = Color(0xFFF6F8FD);

  @override
  Widget build(BuildContext context) {
    final workout = WorkoutPlan.beginnerSample;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 400 ? 18.0 : 24.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                26,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'A fresh start,',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'one workout at a time.',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _TodayWorkoutCard(
                        workoutName: workout.name,
                        duration: workout.durationMinutes,
                        difficulty: workout.difficulty,
                        exerciseCount: workout.exercises.length,
                        onStart: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DailyWorkoutPlanScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Text(
                              'Explore movement',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Text(
                            'Find your rhythm',
                            style: TextStyle(
                              color: Colors.blueGrey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, gridConstraints) {
                          final columns = gridConstraints.maxWidth >= 520
                              ? 4
                              : 2;
                          return GridView.count(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: columns == 4 ? 1.0 : 1.35,
                            children: const [
                              _FeatureCard(
                                icon: Icons.directions_run_rounded,
                                title: 'Cardio',
                                subtitle: 'Get moving',
                                color: Color(0xFFF97316),
                                background: Color(0xFFFFF7ED),
                              ),
                              _FeatureCard(
                                icon: Icons.fitness_center_rounded,
                                title: 'Strength',
                                subtitle: 'Build power',
                                color: Color(0xFF2563EB),
                                background: Color(0xFFEFF6FF),
                              ),
                              _FeatureCard(
                                icon: Icons.self_improvement_rounded,
                                title: 'Yoga',
                                subtitle: 'Find balance',
                                color: Color(0xFF8B5CF6),
                                background: Color(0xFFF5F3FF),
                              ),
                              _FeatureCard(
                                icon: Icons.restaurant_rounded,
                                title: 'Nutrition',
                                subtitle: 'Fuel well',
                                color: Color(0xFF16A34A),
                                background: Color(0xFFF0FDF4),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final String workoutName;
  final int duration;
  final String difficulty;
  final int exerciseCount;
  final VoidCallback onStart;

  const _TodayWorkoutCard({
    required this.workoutName,
    required this.duration,
    required this.difficulty,
    required this.exerciseCount,
    required this.onStart,
  });

  static const Color _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "TODAY'S SESSION",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFDE68A),
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            workoutName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A balanced full-body routine to build a strong foundation.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 19),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SessionPill(
                icon: Icons.schedule_rounded,
                label: '$duration min',
              ),
              _SessionPill(
                icon: Icons.fitness_center_rounded,
                label: '$exerciseCount exercises',
              ),
              _SessionPill(
                icon: Icons.signal_cellular_alt_rounded,
                label: difficulty,
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'Start Workout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SessionPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
