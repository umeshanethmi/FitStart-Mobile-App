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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } on FirebaseAuthException catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Could not log out (${error.code}). Please try again.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const Text(
                'Welcome to FitStart!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready for your workout today?',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateAiPlanScreen()),
                ),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Create Workout Plan'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AiWorkoutPlanScreen(),
                  ),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('My Workout Plans'),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WorkoutScheduleScreen(),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Workout Schedule'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                ),
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('Reminders'),
              ),
              const SizedBox(height: 16),
              // Placeholder for workout modules
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisExtent: 180,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    Icons.directions_run,
                    'Cardio',
                    Colors.orange,
                  ),
                  _buildFeatureCard(
                    Icons.fitness_center,
                    'Strength',
                    Colors.blue,
                  ),
                  _buildFeatureCard(
                    Icons.self_improvement,
                    'Yoga',
                    Colors.purple,
                  ),
                  _buildFeatureCard(Icons.restaurant, 'Diet Plan', Colors.red),
                  _buildFeatureCard(
                    Icons.insights_rounded,
                    'Progress & Analytics',
                    const Color(0xFF2563EB),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProgressAnalyticsScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    Icons.emoji_events_rounded,
                    'Achievements & Trophies',
                    const Color(0xFFF59E0B),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    Icons.support_agent_rounded,
                    'Expert Support',
                    const Color(0xFF0F766E),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ExpertSupportScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    Icons.settings_outlined,
                    'Settings & Privacy',
                    const Color(0xFF475569),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsPrivacyScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
