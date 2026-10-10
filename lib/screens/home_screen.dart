import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/workout_plan.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    final tab = switch (screen) {
      WorkoutScheduleScreen() => WorkoutTab.schedule,
      RemindersScreen() => WorkoutTab.reminders,
      ProgressAnalyticsScreen() => WorkoutTab.progress,
      ExpertSupportScreen() => WorkoutTab.support,
      _ => null,
    };
    if (tab != null && WorkoutNavigationScope.select(context, tab)) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

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
            onPressed: () => context.go('/'),
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
                          context.push('/workouts/beginner-full-body/plan');
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
      );
    }
  }

  @override
  Widget build(BuildContext context) => WorkoutPage(
    title: 'FitStart',
    appBar: AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 68,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, right: 12),
        child: Center(
          child: Tooltip(
            message: 'FitStart logo',
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Color(0xFF00E676),
                size: 28,
                semanticLabel: 'FitStart logo',
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Fit'),
              TextSpan(
                text: 'Start',
                style: TextStyle(color: WorkoutPage.green),
              ),
            ],
          ),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
      shape: const Border(bottom: BorderSide(color: WorkoutPage.line)),
      actions: [
        IconButton(
          tooltip: 'Settings & Privacy',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _open(context, const SettingsPrivacyScreen()),
        ),
        IconButton(
          tooltip: 'Log out',
          icon: const Icon(Icons.logout_outlined),
          onPressed: () => _logout(context),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              const Text(
                'Your training',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'One session at a time.',
                style: TextStyle(color: WorkoutPage.muted, fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 156,
                child: Image.asset(
                  'assets/images/onboarding_1.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.62),
                  semanticLabel: 'Athlete running',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _open(context, const CreateAiPlanScreen()),
                icon: const Icon(Icons.add),
                label: const Text('Create Workout Plan'),
              ),
              const SizedBox(height: 24),
              const WorkoutSectionHeading(
                'Workout hub',
                icon: Icons.fitness_center_outlined,
              ),
              _destination(
                context,
                'Start Workout',
                '${TrainingWorkoutPlan.beginnerSample.name} | ${TrainingWorkoutPlan.beginnerSample.durationMinutes} min',
                Icons.play_circle_outline,
                WorkoutPage.green,
                DailyWorkoutPlanScreen(
                  onWorkoutCompleted: (session) =>
                      WorkoutCompletionService().complete(session),
                ),
              ),
              _destination(
                context,
                'My Workout Plans',
                'Your saved routines',
                Icons.fitness_center_outlined,
                const Color(0xFF15765A),
                const AiWorkoutPlanScreen(),
              ),
              _destination(
                context,
                'Workout Schedule',
                'Your training calendar',
                Icons.calendar_month_outlined,
                const Color(0xFF3264AA),
                const WorkoutScheduleScreen(),
              ),
              _destination(
                context,
                'Reminders',
                'Workout notifications',
                Icons.notifications_outlined,
                const Color(0xFFB94E3A),
                const RemindersScreen(),
              ),
              const SizedBox(height: 24),
              const WorkoutSectionHeading(
                'Your fitness',
                icon: Icons.insights_outlined,
              ),
              _destination(
                context,
                'Progress & Analytics',
                'Activity and workout history',
                Icons.insights_outlined,
                const Color(0xFF3264AA),
                const ProgressAnalyticsScreen(),
              ),
              _destination(
                context,
                'Achievements & Trophies',
                'Your milestones',
                Icons.emoji_events_outlined,
                const Color(0xFFAD7517),
                const AchievementsScreen(),
              ),
              _destination(
                context,
                'Expert Support',
                'Stay connected',
                Icons.support_agent_outlined,
                const Color(0xFF15765A),
                const ExpertSupportScreen(),
              ),
              _destination(
                context,
                'Settings & Privacy',
                'Account preferences',
                Icons.tune,
                WorkoutPage.muted,
                const SettingsPrivacyScreen(),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _destination(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget screen,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: WorkoutPage.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: color, size: 26),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: WorkoutPage.muted, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: WorkoutPage.muted,
        ),
        onTap: () => _open(context, screen),
      ),
    ),
  );
}
