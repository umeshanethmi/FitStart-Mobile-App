import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/goal_selector_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 19,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),

                      // Pill Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'PROFILE SETUP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Title & Subtitle Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Choose Your Role',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.6,
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(left: 4, top: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select your primary role so we can personalize your training journey and features.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Role Selection Cards
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      _buildRoleCard(
                        title: 'Beginner / Athlete',
                        badgeText: 'FITNESS & WORKOUTS',
                        description: 'Track your daily workouts, follow home fitness routines, and hit your fitness milestones.',
                        icon: Icons.fitness_center_rounded,
                        accentColor: const Color(0xFF2563EB),
                        roleValue: 'Beginner',
                      ),
                      const SizedBox(height: 14),
                      _buildRoleCard(
                        title: 'Fitness Trainer',
                        badgeText: 'COACH & INSTRUCTOR',
                        description: 'Create custom workout programs, monitor client progress, and coach your athletes.',
                        icon: Icons.sports_rounded,
                        accentColor: const Color(0xFFEA580C),
                        roleValue: 'Trainer',
                      ),
                      const SizedBox(height: 14),
                      _buildRoleCard(
                        title: 'Physical Therapist',
                        badgeText: 'CLINICAL & REHAB',
                        description: 'Provide medical recovery plans, injury rehab guidance, and safety compliance.',
                        icon: Icons.medical_services_rounded,
                        accentColor: const Color(0xFF059669),
                        roleValue: 'Therapist',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selectedRole != null ? _navigateToNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        elevation: _selectedRole != null ? 4 : 0,
                        shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _selectedRole != null ? Colors.white : const Color(0xFF94A3B8),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                            color: _selectedRole != null ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String badgeText,
    required String description,
    required IconData icon,
    required Color accentColor,
    required String roleValue,
  }) {
    final isSelected = _selectedRole == roleValue;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vibrant Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : accentColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Card Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtle Tag Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Selection Radio / Check Indicator
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? accentColor : const Color(0xFFCBD5E1),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainerDashboardPlaceholder extends StatelessWidget {
  const TrainerDashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFFF8FAFC), body: Center(child: Text('Trainer Dashboard', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold))));
}

class TherapistDashboardPlaceholder extends StatelessWidget {
  const TherapistDashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Color(0xFFF8FAFC), body: Center(child: Text('Therapist Dashboard', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold))));
}
