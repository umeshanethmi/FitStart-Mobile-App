import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/goal_selector_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _navigateToNext() {
    if (_selectedRole == null) return;
    
    Widget nextScreen;
    switch (_selectedRole) {
      case 'Trainer':
        nextScreen = const TrainerDashboardPlaceholder();
        break;
      case 'Therapist':
        nextScreen = const TherapistDashboardPlaceholder();
        break;
      case 'Beginner':
      default:
        nextScreen = const GoalSelectorScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
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
                'Choose Your Role',
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
                'Select your primary role so we can personalize your experience.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Role Cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRoleCard(
                      title: 'Beginner',
                      description: 'I want to track workouts and follow home fitness plans.',
                      icon: Icons.fitness_center_rounded,
                      roleValue: 'Beginner',
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      title: 'Trainer',
                      description: 'I am a fitness instructor managing client plans.',
                      icon: Icons.sports_rounded,
                      roleValue: 'Trainer',
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      title: 'Physical Therapist',
                      description: 'I provide medical & safety guidance for users.',
                      icon: Icons.medical_services_rounded,
                      roleValue: 'Therapist',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedRole != null
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
                  onPressed: _selectedRole != null ? _navigateToNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    disabledBackgroundColor: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedRole != null ? Colors.black87 : Colors.grey.shade600,
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

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String roleValue,
  }) {
    final isSelected = _selectedRole == roleValue;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
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

class TrainerDashboardPlaceholder extends StatelessWidget {
  const TrainerDashboardPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF121212), body: Center(child: Text('Trainer Dashboard', style: TextStyle(color: Colors.white))));
}

class TherapistDashboardPlaceholder extends StatelessWidget {
  const TherapistDashboardPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFF121212), body: Center(child: Text('Therapist Dashboard', style: TextStyle(color: Colors.white))));
}
