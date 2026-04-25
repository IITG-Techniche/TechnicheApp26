import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/utils/errorHandler.dart';

class CaRegisterScreen extends ConsumerStatefulWidget {
  static const String routeName = '/ca-register-screen';
  const CaRegisterScreen({super.key});

  @override
  ConsumerState<CaRegisterScreen> createState() => _CaRegisterScreenState();
}

class _CaRegisterScreenState extends ConsumerState<CaRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final institutionController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await ref.read(caAuthControllerProvider).registerUser(
      context: context,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      contact: contactController.text.trim(),
      institution: institutionController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      password: passwordController.text.trim(),
    );
    
    if (mounted) setState(() => _isLoading = false);
    // Success handling (dialog/navigation) is inside the controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              physics: const BouncingScrollPhysics(),
              child: _buildRegisterForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF6D7985),
                    size: 20,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              const Text(
                'CA REGISTRATION',
                style: TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Univers',
                  height: 1.2,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(flex: 1),
              const SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Join the Program",
              style: TextStyle(
                fontFamily: 'Univers',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0XFF232930),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildTextField(
              label: "Full Name",
              controller: nameController,
              icon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? "Enter your name" : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Email Address",
              controller: emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (!v!.contains('@')) ? "Enter valid email" : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Contact Number",
              controller: contactController,
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.length < 10 ? "Enter valid number" : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Institution / College",
              controller: institutionController,
              icon: Icons.school_outlined,
              validator: (v) => v!.isEmpty ? "Enter college name" : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "City",
                    controller: cityController,
                    icon: Icons.location_city_rounded,
                    validator: (v) => v!.isEmpty ? "Enter city" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: "State",
                    controller: stateController,
                    icon: Icons.map_outlined,
                    validator: (v) => v!.isEmpty ? "Enter state" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Password",
              controller: passwordController,
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: (v) => v!.length < 6 ? "Minimum 6 characters" : null,
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002B5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "CREATE ACCOUNT",
                style: TextStyle(
                  fontFamily: 'Univers',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'General Sans', color: Color(0xFF6D7985)),
                    children: [
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Sign In",
                        style: TextStyle(color: Color(0xFF002B5B), fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Univers',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF6D7985),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontFamily: 'General Sans', fontSize: 14, color: Color(0XFF232930)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6D7985)),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18,
                color: const Color(0xFF6D7985),
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ) : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF002B5B), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: const TextStyle(fontFamily: 'General Sans', fontSize: 11),
          ),
        ),
      ],
    );
  }
}
