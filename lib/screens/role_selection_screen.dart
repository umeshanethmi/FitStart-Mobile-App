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
      backgroundColor: const Color(0xFFF6F8FD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Your Role',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select your primary role so we can personalize your experience.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  _buildRoleCard(
                    title: 'Beginner',
                    description: 'I want to track workouts and follow home fitness plans.',
                    icon: Icons.fitness_center_rounded,
                    roleValue: 'Beginner',
                  ),
                  const SizedBox(height: 16),
                  _buildRoleCard(
                    title: 'Trainer',
                    description: 'I am a fitness instructor managing client plans.',
                    icon: Icons.sports_rounded,
                    roleValue: 'Trainer',
                  ),
                  const SizedBox(height: 16),
                  _buildRoleCard(
                    title: 'Physical Therapist',
                    description: 'I provide medical & safety guidance for users.',
                    icon: Icons.medical_services_rounded,
                    roleValue: 'Therapist',
                  ),
                ],
              ),
            ),
            
            // Bottom Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedRole != null
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _navigateToNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _selectedRole != null ? Colors.white : Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: _selectedRole != null ? Colors.white : Colors.grey.shade500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
                size: 24,
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
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFFF6F8FD), body: Center(child: Text('Trainer Dashboard', style: TextStyle(color: Color(0xFF0F172A)))));
}

class TherapistDashboardPlaceholder extends StatelessWidget {
  const TherapistDashboardPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFFF6F8FD), body: Center(child: Text('Therapist Dashboard', style: TextStyle(color: Color(0xFF0F172A)))));
}
