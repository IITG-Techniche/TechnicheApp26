/// This screen handles the login UI for Campus Ambassador users.
library;
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techniche26/view/auth/ca_register_screen.dart';

class CaAuthScreen extends ConsumerStatefulWidget {
  static const String routeName = '/ca-auth-screen';
  const CaAuthScreen({super.key});

  @override
  ConsumerState<CaAuthScreen> createState() => _CaAuthScreenState();
}

class _CaAuthScreenState extends ConsumerState<CaAuthScreen> {
  var signInKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isSigningIn = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _submit(String email, String password) async {
    final isValid = signInKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    signInKey.currentState!.save();

    setState(() {
      _isSigningIn = true;
    });

    try {
      final success = await ref.read(caAuthControllerProvider).signInUser(
            context: context,
            email: email,
            password: password,
          );
      
      // Navigation is handled inside the controller on success
    } catch (e) {
      if (mounted) {
        showMessage(context, "Failed to sign in. Please try again.",
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Reset Password", style: TextStyle(fontFamily: 'Univers', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your registered email to receive a password reset link.",
                style: TextStyle(fontFamily: 'General Sans')),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: "Email Address",
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'General Sans', color: Color(0xFF6D7985))),
          ),
          TextButton(
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                Navigator.pop(ctx);
                ref.read(caAuthControllerProvider).requestPasswordReset(context, email);
              } else {
                showMessage(context, "Enter a valid email", isError: true);
              }
            },
            child: const Text("Send Link", style: TextStyle(fontFamily: 'Univers', fontWeight: FontWeight.bold, color: Color(0xFF002B5B))),
          ),
        ],
      ),
    );
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
              child: _buildLoginForm(),
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
                'CA LOGIN',
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
              const SizedBox(width: 32), // Balance for back button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: signInKey,
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
              "Access Dashboard",
              style: TextStyle(
                fontFamily: 'Univers',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0XFF232930),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Please sign in with your Campus Ambassador credentials to continue.",
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 14,
                color: const Color(0XFF232930).withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildTextField(
              label: "Email Address",
              controller: emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return "Please enter a valid email address";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Password",
              controller: passwordController,
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF002B5B),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isSigningIn ? null : () => _submit(emailController.text, passwordController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002B5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFF002B5B).withOpacity(0.5),
              ),
              child: _isSigningIn 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "SIGN IN",
                    style: TextStyle(
                      fontFamily: 'Univers',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE8E8E8))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D7985).withOpacity(0.5),
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE8E8E8))),
              ],
            ),
            
            const SizedBox(height: 24),
            
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, CaRegisterScreen.routeName),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE8E8E8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 20, color: Color(0xFF002B5B)),
                  SizedBox(width: 12),
                  Text(
                    "REGISTER AS CA",
                    style: TextStyle(
                      fontFamily: 'Univers',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B5B),
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
          style: const TextStyle(fontFamily: 'General Sans', fontSize: 15, color: Color(0XFF232930)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6D7985)),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: const Color(0xFF6D7985),
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ) : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
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
