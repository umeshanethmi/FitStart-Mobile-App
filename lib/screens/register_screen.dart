import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/screens/login_screen.dart';
import 'package:fitstart_mobile_app/screens/role_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = true;

  void _register() async {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      setState(() => _isLoading = true);
      
      final user = await _authService.registerWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration failed. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE3EDFE),
                    Color(0xFFF6F8FD),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header Row
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
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'STEP 1 OF 3',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 48), // Balance for back button
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logo
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF00E676),
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Alex Morgan',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.grey.shade400, size: 20),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'alex@example.com',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.grey.shade400, size: 20),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                      ),
                      validator: (value) => value == null || !value.contains('@') ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Strong',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6 ? 'Password too short' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // Password requirements
                    Row(
                      children: [
                        _buildRequirement(Icons.check_rounded, '8+ chars'),
                        const SizedBox(width: 12),
                        _buildRequirement(Icons.check_rounded, '1 number'),
                        const SizedBox(width: 12),
                        _buildRequirement(Icons.check_rounded, 'Special char'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Terms Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) => setState(() => _agreedToTerms = value ?? true),
                            activeColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                              children: const [
                                TextSpan(text: 'I agree to FitStart\'s '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Color(0xFF2563EB), decoration: TextDecoration.underline),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(color: Color(0xFF2563EB), decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign Up Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_agreedToTerms) ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Or continue with divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Social Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.apple, color: Colors.black),
                            label: const Text(
                              'Apple',
                              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade200),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.black, size: 30),
                            label: const Text(
                              'Google',
                              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade200),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Log In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}