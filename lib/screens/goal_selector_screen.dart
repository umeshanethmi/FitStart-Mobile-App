import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/physical_profile_screen.dart';

class GoalSelectorScreen extends StatefulWidget {
  const GoalSelectorScreen({super.key});

  @override
  State<GoalSelectorScreen> createState() => _GoalSelectorScreenState();
}

class _GoalSelectorScreenState extends State<GoalSelectorScreen> {
  String? _selectedGoal;

  void _navigateToNext() {
    if (_selectedGoal != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhysicalProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'What is your goal?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Select your primary goal so we can tailor your experience.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildGoalCard(
                      title: 'Lose Weight',
                      description: 'Burn calories and shed fat.',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildGoalCard(
                      title: 'Build Muscle',
                      description: 'Increase strength and muscle mass.',
                      icon: Icons.fitness_center_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildGoalCard(
                      title: 'Stay Fit',
                      description: 'Maintain overall health and wellness.',
                      icon: Icons.monitor_heart_rounded,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedGoal != null
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: _selectedGoal != null ? _navigateToNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    disabledBackgroundColor: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedGoal != null ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedGoal == title;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676).withOpacity(0.1) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00E676) : const Color(0xFF2C2C2C),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black87 : Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF00E676) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00E676),
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
