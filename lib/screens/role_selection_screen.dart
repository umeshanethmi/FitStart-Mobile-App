import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/login_screen.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isSaving = false;

  void _navigateToNext() async {
    final role = _selectedRole;
    if (role == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        if (role == 'Trainer' || role == 'Therapist') {
          final normalizedRole = role == 'Trainer' ? 'coach' : 'therapist';
          final displayName = user.name.trim().isNotEmpty
              ? user.name.trim()
              : (normalizedRole == 'coach'
                  ? 'Fitness Coach'
                  : 'Physical Therapist');
          final specialization = normalizedRole == 'coach'
              ? 'Personal Training & Fitness'
              : 'Physical Therapy & Recovery';
          final bio = normalizedRole == 'coach'
              ? 'Certified fitness trainer ready to help you reach your goals.'
              : 'Certified physical therapist specialized in mobility and recovery.';

          await DatabaseService().createUserProfile(user.id, {
            'role': normalizedRole,
            'isApproved': true,
            'isAvailable': true,
            'specialization': specialization,
            'bio': bio,
            'experience': 3,
            'name': displayName,
            'email': user.email,
          });

          // Also publish directly to expert_directory so members see this coach/therapist
          await FirebaseFirestore.instance
              .collection('expert_directory')
              .doc(user.id)
              .set({
            'name': displayName,
            'role': normalizedRole,
            'specialization': specialization,
            'bio': bio,
            'photoUrl': '',
            'experience': 3,
            'isAvailable': true,
            'isApproved': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await DatabaseService().createUserProfile(user.id, {
            'role': 'user',
            'isApproved': false,
          });
        }
      }

      // Sign out so user logs into the unified login screen with their credentials
      await AuthService().signOut();

      if (!mounted) return;

      final roleLabel = role == 'Trainer'
          ? 'Coach'
          : role == 'Therapist'
              ? 'Therapist'
              : 'Athlete';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$roleLabel registered successfully! Please sign in with your credentials.',
          ),
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Error saving role: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving role: $e"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF2563EB);

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
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
                                color: brandBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'PROFILE SETUP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: brandBlue,
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
                              color: brandBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select your role to personalize your training journey and tools.',
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
                        description: 'Track workouts and home fitness plans.',
                        icon: Icons.fitness_center_rounded,
                        roleValue: 'Beginner',
                      ),
                      const SizedBox(height: 14),
                      _buildRoleCard(
                        title: 'Fitness Trainer',
                        badgeText: 'COACH & INSTRUCTOR',
                        description: 'Manage clients and custom workout plans.',
                        icon: Icons.sports_rounded,
                        roleValue: 'Trainer',
                      ),
                      const SizedBox(height: 14),
                      _buildRoleCard(
                        title: 'Physical Therapist',
                        badgeText: 'CLINICAL & REHAB',
                        description: 'Injury rehabilitation and recovery care.',
                        icon: Icons.medical_services_rounded,
                        roleValue: 'Therapist',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (_selectedRole != null && !_isSaving)
                          ? _navigateToNext
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        elevation: (_selectedRole != null && !_isSaving) ? 4 : 0,
                        shadowColor: brandBlue.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedRole != null
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 19,
                                  color: _selectedRole != null
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
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
    required String roleValue,
  }) {
    final isSelected = _selectedRole == roleValue;
    const brandBlue = Color(0xFF2563EB);

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? brandBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? brandBlue.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Blue Icon Box (consistent brand color for all roles)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? brandBlue : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : brandBlue,
                  size: 23,
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Card Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtle Tag Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: brandBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Short Clean Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
