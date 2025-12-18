/// This screen handles the login UI for Campus Ambassador users.
library;
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techniche26/utils/animate_gradient_background.dart';

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
      await ref.read(caAuthControllerProvider).signInUser(
            context: context,
            email: email,
            password: password,
          );
    } catch (e) {
      showMessage(context, "Failed to sign in. Please try again.",
          isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.techniche.org.in/ca');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      showMessage(context, 'Could not launch $url', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    final double verticalPadding = screenHeight * 0.02;
    final double horizontalPadding = screenWidth * 0.05;
    final double buttonHeight = screenHeight * 0.06;
    final double spaceBetween = screenHeight * 0.015;

    final double headingSize = screenWidth * 0.07;
    final double subheadingSize = screenWidth * 0.04;
    final double bodyTextSize = screenWidth * 0.04;
    final double smallTextSize = screenWidth * 0.035;

    const accentColor = Colors.blueAccent;
    final disabledColor = Colors.grey.shade800;

    final inputDecoration = BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF2E2F36), Color(0xFF23242B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(4, 4),
        ),
        BoxShadow(
          color: Colors.blueAccent.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
      border: Border.all(
        color: Colors.blueAccent.withOpacity(0.25),
        width: 1,
      ),
    );

    final disabledInputDecoration = BoxDecoration(
      color: const Color(0xFF2a2b30),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade800.withOpacity(0.5),
        width: 1,
      ),
    );

    return Stack(
      children: [
        const AnimatedGradientBackground(),
        Scaffold(
          backgroundColor: const Color(0xFF181A20),
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color(0xFF181A20),
              statusBarIconBrightness: Brightness.light,
            ),
            backgroundColor: const Color(0xFF23242B),
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: SizedBox(
              width: screenWidth * 0.38,
              child: Image.asset(
                'assets/logo_withoutBG.png',
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.8,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: signInKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Sign in to the Techniche CA Portal",
                            style: TextStyle(
                              fontSize: subheadingSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spaceBetween * 1.5),
                          Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: headingSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: spaceBetween * 1.5),

                          // Email TextField
                          Container(
                            decoration: _isSigningIn
                                ? disabledInputDecoration
                                : inputDecoration,
                            child: TextFormField(
                              controller: emailController,
                              enabled: !_isSigningIn,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                  fontSize: bodyTextSize, color: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty ||
                                    !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value)) {
                                  return "  Please enter a valid email address";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                hintText: "Email Address",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                              ),
                            ),
                          ),
                          SizedBox(height: spaceBetween),

                          // Password TextField
                          Container(
                            decoration: _isSigningIn
                                ? disabledInputDecoration
                                : inputDecoration,
                            child: TextFormField(
                              controller: passwordController,
                              enabled: !_isSigningIn,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(
                                  fontSize: bodyTextSize, color: Colors.white),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "  Password cannot be empty";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                hintText: "Password",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: _isSigningIn
                                      ? null
                                      : () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                ),
                              ),
                            ),
                          ),

                          CheckboxListTile(
                            value: _isPasswordVisible,
                            onChanged: _isSigningIn
                                ? null
                                : (value) {
                                    setState(() {
                                      _isPasswordVisible = value!;
                                    });
                                  },
                            title: Text(
                              "Show Password",
                              style: TextStyle(
                                  fontSize: bodyTextSize, color: Colors.white),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: accentColor,
                            checkColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                          ),
                          SizedBox(height: spaceBetween),
                          Center(
                            child: InkWell(
                              onTap: _isSigningIn
                                  ? null
                                  : () => _submit(emailController.text,
                                      passwordController.text),
                              child: Container(
                                width: screenWidth * 0.9,
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  color: _isSigningIn
                                      ? disabledColor
                                      : accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: _isSigningIn
                                      ? SizedBox(
                                          height: bodyTextSize * 1.2,
                                          width: bodyTextSize * 1.2,
                                          child:
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: bodyTextSize,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spaceBetween),
                          Divider(color: Colors.grey.shade800),
                          SizedBox(height: spaceBetween),
                          Center(
                            child: Text(
                              "Haven't registered yet?",
                              style: TextStyle(
                                  fontSize: bodyTextSize,
                                  color: Colors.grey.shade300),
                            ),
                          ),
                          SizedBox(height: spaceBetween * 0.5),
                          Center(
                            child: InkWell(
                              onTap: _isSigningIn ? null : _launchURL,
                              child: Container(
                                width: screenWidth * 0.9,
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _isSigningIn
                                          ? disabledColor
                                          : Colors.grey.shade700),
                                ),
                                child: Center(
                                  child: Text(
                                    "Create Account on CA Portal",
                                    style: TextStyle(
                                      fontSize: bodyTextSize,
                                      fontWeight: FontWeight.w500,
                                      color: _isSigningIn
                                          ? disabledColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: _isSigningIn ? null : () {},
                                child: Text(
                                  "Conditions for Use",
                                  style: TextStyle(
                                    fontSize: smallTextSize,
                                    color: _isSigningIn
                                        ? disabledColor
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _isSigningIn ? null : () {},
                                child: Text(
                                  "Privacy Notice",
                                  style: TextStyle(
                                    fontSize: smallTextSize,
                                    color: _isSigningIn
                                        ? disabledColor
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                              "© 2025, Techniche, IIT Guwahati",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: smallTextSize * 0.9,
                              ),
                            ),
                          ),
                          SizedBox(height: verticalPadding),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
