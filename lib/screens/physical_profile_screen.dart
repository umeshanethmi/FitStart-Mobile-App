import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/home_screen.dart';

class PhysicalProfileScreen extends StatefulWidget {
  const PhysicalProfileScreen({super.key});

  @override
  State<PhysicalProfileScreen> createState() => _PhysicalProfileScreenState();
}

class _PhysicalProfileScreenState extends State<PhysicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  void _completeProfile() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Physical Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us personalize your AI workout plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Height Field
                  TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.height_rounded, color: Color(0xFF00E676)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00E676), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Weight Field
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.monitor_weight_rounded, color: Color(0xFF00E676)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00E676), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Age Field
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Age',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.cake_rounded, color: Color(0xFF00E676)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00E676), width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (int.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 48),
                  
                  // Continue Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _completeProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Finish Setup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
