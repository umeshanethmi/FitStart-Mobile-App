import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Sign out and navigate back to Welcome Screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              
              // Placeholder for workout modules
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(Icons.directions_run, 'Cardio', Colors.orange),
                    _buildFeatureCard(Icons.fitness_center, 'Strength', Colors.blue),
                    _buildFeatureCard(Icons.self_improvement, 'Yoga', Colors.purple),
                    _buildFeatureCard(Icons.restaurant, 'Diet Plan', Colors.red),
                  ],
                ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
