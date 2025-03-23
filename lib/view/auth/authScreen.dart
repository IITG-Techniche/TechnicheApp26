import 'package:amazon_clone/controller/authController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var signInKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  void _submit(String email, String password) async {
    final isValid = signInKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    signInKey.currentState!.save();

    // Notice we don't need to handle navigation here as your AuthController
    // already does the navigation on successful login
    await AuthController().signInUser(
      context: context,
      email: email,
      password: password,
    );
    // The AuthController will navigate to BottomNavBar on success
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.techniche.org.in/ca');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Calculate adaptive sizes based on screen dimensions
    final double verticalPadding = screenHeight * 0.02;
    final double horizontalPadding = screenWidth * 0.04;
    final double buttonHeight = screenHeight * 0.06;
    final double spaceBetween = screenHeight * 0.015;

    // Text sizes based on screen width
    final double headingSize = screenWidth * 0.06;
    final double subheadingSize = screenWidth * 0.045;
    final double bodyTextSize = screenWidth * 0.04;
    final double smallTextSize = screenWidth * 0.035;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.08),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.orange,
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Colors.orange,
          flexibleSpace: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: constraints.maxHeight * 0.1,
                    horizontal: horizontalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.06,
                      maxWidth: screenWidth * 0.6,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo_withoutBG.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          elevation: 0.0,
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
                        "Sign in with your email and password",
                        style: TextStyle(
                          fontSize: subheadingSize,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spaceBetween * 1.5),
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: headingSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spaceBetween),
                      // Email TextField
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: bodyTextSize),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your registered email",
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 119, 115, 115),
                            fontSize: bodyTextSize,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding * 0.8,
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: spaceBetween),
                      // Password TextField
                      TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        style: TextStyle(fontSize: bodyTextSize),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter password";
                          }
                          return null;
                        },
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 119, 115, 115),
                            fontSize: bodyTextSize,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding * 0.8,
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: bodyTextSize * 1.2,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      // Show Password CheckboxListTile
                      CheckboxListTile(
                        value: _isPasswordVisible,
                        onChanged: (value) {
                          setState(() {
                            _isPasswordVisible = value!;
                          });
                        },
                        title: Text(
                          "Show Password",
                          style: TextStyle(fontSize: bodyTextSize),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding * 0.5,
                        ),
                      ),
                      SizedBox(height: spaceBetween),
                      // Sign In Button
                      Center(
                        child: InkWell(
                          onTap: () => _submit(
                              emailController.text, passwordController.text),
                          child: Container(
                            width: screenWidth * 0.9,
                            height: buttonHeight * 1.1,
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: bodyTextSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spaceBetween),
                      Divider(thickness: 1),
                      SizedBox(height: spaceBetween),
                      Center(
                        child: Text(
                          "Haven't registered yet?",
                          style: TextStyle(fontSize: bodyTextSize),
                        ),
                      ),
                      SizedBox(height: spaceBetween * 0.5),
                      // Create Account Button
                      Center(
                        child: InkWell(
                          onTap: _launchURL,
                          child: Container(
                            width: screenWidth * 0.9,
                            height: buttonHeight * 1.1,
                            decoration: BoxDecoration(
                              color: Colors.orange[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                "Create Account on CA Portal Website",
                                style: TextStyle(
                                  fontSize: bodyTextSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Spacer to push footer to bottom
                      Spacer(),
                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Conditions for Use",
                              style: TextStyle(fontSize: smallTextSize),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Privacy Notice",
                              style: TextStyle(fontSize: smallTextSize),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Help",
                              style: TextStyle(fontSize: smallTextSize),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          "Copyright: 2025, Techniche, IIT Guwahati, Inc. or its affiliates",
                          style: TextStyle(
                            color: Colors.blueGrey[800],
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
    );
  }
}
