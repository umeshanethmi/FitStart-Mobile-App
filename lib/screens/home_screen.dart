import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';
import 'package:fitstart_mobile_app/screens/create_ai_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/ai_workout_plan_screen.dart';
import 'package:fitstart_mobile_app/screens/workout_schedule_screen.dart';
import 'package:fitstart_mobile_app/screens/reminders_screen.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';

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
              await AuthService().signOut();
              if (!context.mounted) return;
              // Sign out and navigate back to Welcome Screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
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
                mainAxisExtent: 150,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
