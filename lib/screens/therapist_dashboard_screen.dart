import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  static const Color _brandBlue = Color(0xFF2563EB);

  void _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _showPatientDetailModal(
    String name,
    String condition,
    String phase,
    String painLevel,
    Color painColor,
    String notes,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  child: Text(
                    name.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        condition,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rehab Phase', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      Text(phase, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reported Pain Index', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: painColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          painLevel,
                          style: TextStyle(fontWeight: FontWeight.w800, color: painColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clinical Notes: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      Expanded(
                        child: Text(
                          notes,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting rehab evaluation with $name'),
                          backgroundColor: const Color(0xFF0D9488),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Conduct Evaluation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showToolNotice(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title opened'),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Therapist Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Clinical Alerts',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No urgent patient clinical alerts'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Clinical Rehab',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Monitor recovery protocols and patient mobility progression.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF99F6E4)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: Color(0xFF0D9488),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // KPI Stats Grid (Row of 3 cards)
              Row(
                children: [
                  _buildStatCard(
                    title: 'Patients',
                    value: '12',
                    subtitle: 'Under recovery',
                    icon: Icons.personal_injury_rounded,
                    color: const Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: 'Protocols',
                    value: '8',
                    subtitle: 'Active therapy',
                    icon: Icons.assignment_rounded,
                    color: _brandBlue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: 'Check-ins',
                    value: '3',
                    subtitle: 'Scheduled today',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Section: Today's Patient Consultations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Patients",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showToolNotice('Patient Clinical Registry'),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: _brandBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildPatientCard(
                name: 'Michael Reed',
                condition: 'Post-ACL Reconstruction (Week 6)',
                time: '10:00 AM · Rehabilitation',
                phase: 'Phase 2: Joint Mobility',
                painScore: 'Pain: 2/10 (Low)',
                painColor: const Color(0xFF10B981),
                notes: 'Range of motion improved by 15 degrees. Good quad activation.',
              ),
              const SizedBox(height: 12),

              _buildPatientCard(
                name: 'Emma Watson',
                condition: 'Lumbar Spine Herniation',
                time: '01:30 PM · Follow-up',
                phase: 'Core & Spine Stabilization',
                painScore: 'Pain: 4/10 (Moderate)',
                painColor: const Color(0xFFF59E0B),
                notes: 'Avoid heavy spinal loading. Focus on bird-dog and gentle pelvic tilts.',
              ),
              const SizedBox(height: 12),

              _buildPatientCard(
                name: 'Lucas Brown',
                condition: 'Rotator Cuff Tendinopathy',
                time: '04:15 PM · Progress Check',
                phase: 'Shoulder Strength Recovery',
                painScore: 'Pain: 1/10 (Minimal)',
                painColor: const Color(0xFF10B981),
                notes: 'Band external rotations completed daily without impingement.',
              ),

              const SizedBox(height: 26),

              // Section: Clinical Rehab Toolkit
              const Text(
                'Rehabilitation Toolkit',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.25,
                children: [
                  _buildToolCard(
                    title: 'Prescribe Routine',
                    description: 'Low-impact rehab exercises',
                    icon: Icons.healing_rounded,
                    color: const Color(0xFF0D9488),
                    onTap: () => _showToolNotice('Prescribe Routine Tool'),
                  ),
                  _buildToolCard(
                    title: 'Mobility & Pain',
                    description: 'Track range of motion',
                    icon: Icons.monitor_heart_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () => _showToolNotice('Mobility & Pain Tracker'),
                  ),
                  _buildToolCard(
                    title: 'Recovery Protocols',
                    description: 'Ice, heat & stretching',
                    icon: Icons.ac_unit_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => _showToolNotice('Recovery Protocols'),
                  ),
                  _buildToolCard(
                    title: 'Clinical Notes',
                    description: 'Physician discharge reports',
                    icon: Icons.description_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => _showToolNotice('Clinical Notes & Reports'),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Section: Patient Recovery Updates
              const Text(
                'Recovery Milestones',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMilestoneItem(
                      patient: 'Michael Reed',
                      milestone: 'Achieved 120° knee flexion target without swelling.',
                      date: 'Today',
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFF10B981),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildMilestoneItem(
                      patient: 'Emma Watson',
                      milestone: 'Completed full week of lumbar decompression exercises.',
                      date: 'Yesterday',
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF0D9488),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildMilestoneItem(
                      patient: 'Lucas Brown',
                      milestone: 'Cleared for bodyweight pushups following rotator assessment.',
                      date: '2 days ago',
                      icon: Icons.verified_rounded,
                      iconColor: _brandBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard({
    required String name,
    required String condition,
    required String time,
    required String phase,
    required String painScore,
    required Color painColor,
    required String notes,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPatientDetailModal(name, condition, phase, painScore, painColor, notes),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFFCCFBF1),
                  child: Text(
                    name.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: painColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              painScore,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: painColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        condition,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneItem({
    required String patient,
    required String milestone,
    required String date,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 17),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  milestone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
