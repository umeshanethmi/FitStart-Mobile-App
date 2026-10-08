import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitstart_mobile_app/screens/progress_analytics_screen.dart';
import 'package:fitstart_mobile_app/screens/achievements_screen.dart';
import 'package:fitstart_mobile_app/screens/expert_support_screen.dart';
import 'package:fitstart_mobile_app/screens/settings_privacy_screen.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/screens/login_screen.dart';
import 'package:fitstart_mobile_app/screens/create_ai_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/ai_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/screens/reminders_screen.dart';
import 'package:fitstart_mobile_app/widgets/workout_page.dart';
import 'package:fitstart_mobile_app/screens/daily_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/models/training_workout_plan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not log out (${error.code}). Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => WorkoutPage(
    title: 'FitStart',
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
                const DailyWorkoutPlanScreen(),
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
