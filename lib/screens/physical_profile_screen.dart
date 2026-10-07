import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';
import 'package:fitstart_mobile_app/services/database_service.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';

class PhysicalProfileScreen extends StatefulWidget {
  final String goal;
  const PhysicalProfileScreen({super.key, required this.goal});

  @override
  State<PhysicalProfileScreen> createState() => _PhysicalProfileScreenState();
}

class _PhysicalProfileScreenState extends State<PhysicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedActivity = 'Moderate';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  double? get _bmi {
    final h = double.tryParse(_heightController.text.trim());
    final w = double.tryParse(_weightController.text.trim());
    if (h != null && w != null && h > 80 && h < 250 && w > 20 && w < 300) {
      final meters = h / 100.0;
      return w / (meters * meters);
    }
    return null;
  }

  String get _bmiCategory {
    final bmi = _bmi;
    if (bmi == null) return '';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Healthy Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'High BMI';
  }

  Color get _bmiColor {
    final bmi = _bmi;
    if (bmi == null) return const Color(0xFF2563EB);
    if (bmi < 18.5) return const Color(0xFFF59E0B);
    if (bmi < 25.0) return const Color(0xFF10B981);
    if (bmi < 30.0) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  void _completeProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authService = AuthService();
        final dbService = DatabaseService();
        final user = authService.currentUser;

        if (user != null) {
          final profileData = {
            'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
            'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
            'age': int.tryParse(_ageController.text.trim()) ?? 0,
            'gender': _selectedGender,
            'activityLevel': _selectedActivity,
            'goal': widget.goal,
            if (_bmi != null) 'bmi': double.parse(_bmi!.toStringAsFixed(1)),
          };

          await dbService.createUserProfile(user.id, profileData);
          await dbService.generateRuleBasedPlan(user.id, widget.goal);
        }

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF2563EB);
    final currentBmi = _bmi;

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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
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
                  ),
                ),

                const SizedBox(height: 8),

                // Main Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Headline
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Physical Profile',
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
                            'Enter your biometrics to calibrate your AI workout routine.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.45,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 1. Biological Sex / Gender Selector
                          const Text(
                            'BIOLOGICAL SEX',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildGenderOption('Male', Icons.male_rounded),
                              const SizedBox(width: 10),
                              _buildGenderOption('Female', Icons.female_rounded),
                              const SizedBox(width: 10),
                              _buildGenderOption('Other', Icons.person_outline_rounded),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 2. Biometric Input Fields
                          _buildBiometricCard(
                            label: 'HEIGHT',
                            controller: _heightController,
                            icon: Icons.height_rounded,
                            unit: 'cm',
                            hint: '175',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter your height';
                              final val = double.tryParse(v);
                              if (val == null || val < 50 || val > 260) return 'Enter valid height (50-260 cm)';
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _buildBiometricCard(
                            label: 'WEIGHT',
                            controller: _weightController,
                            icon: Icons.monitor_weight_outlined,
                            unit: 'kg',
                            hint: '70.5',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter your weight';
                              final val = double.tryParse(v);
                              if (val == null || val < 20 || val > 300) return 'Enter valid weight (20-300 kg)';
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _buildBiometricCard(
                            label: 'AGE',
                            controller: _ageController,
                            icon: Icons.cake_outlined,
                            unit: 'years',
                            hint: '25',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter your age';
                              final val = int.tryParse(v);
                              if (val == null || val < 10 || val > 120) return 'Enter valid age (10-120)';
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // 3. Activity Level Chips
                          const Text(
                            'ACTIVITY LEVEL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildActivityOption('Sedentary', 'Little exercise'),
                              const SizedBox(width: 8),
                              _buildActivityOption('Moderate', '3-4 days/wk'),
                              const SizedBox(width: 8),
                              _buildActivityOption('Active', '5+ days/wk'),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 4. Advanced Live AI Calibration Insight Card
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: currentBmi != null ? _bmiColor.withValues(alpha: 0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: currentBmi != null ? _bmiColor.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: currentBmi != null ? _bmiColor.withValues(alpha: 0.12) : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      currentBmi != null ? Icons.health_and_safety_rounded : Icons.auto_awesome_rounded,
                                      color: currentBmi != null ? _bmiColor : brandBlue,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (currentBmi != null) ...[
                                        Row(
                                          children: [
                                            Text(
                                              'BMI: ${currentBmi.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: _bmiColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _bmiColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                _bmiCategory,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: _bmiColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Calibrating custom ${widget.goal} workout plans.',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ] else ...[
                                        const Text(
                                          'AI Biometric Calibration',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Enter height & weight to calculate live BMI metrics.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Finish Setup Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _completeProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        elevation: 4,
                        shadowColor: brandBlue.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Finish Setup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 19,
                                  color: Colors.white,
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

  Widget _buildGenderOption(String label, IconData icon) {
    final isSelected = _selectedGender == label;
    const brandBlue = Color(0xFF2563EB);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? brandBlue : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? brandBlue.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? brandBlue : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? brandBlue : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityOption(String title, String subtitle) {
    final isSelected = _selectedActivity == title;
    const brandBlue = Color(0xFF2563EB);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedActivity = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? brandBlue : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? brandBlue : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String unit,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    const brandBlue = Color(0xFF2563EB);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: brandBlue,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Field Input + Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    validator: validator,
                  ),
                ],
              ),
            ),

            // Unit Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
