import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/controller/authController.dart';
// ignore: unused_import
import 'package:amazon_clone/constant/global.dart';

class LandingScreen extends StatelessWidget {
  static const String routeName = '/landing-screen';

  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.085),
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
                    horizontal: screenWidth * 0.05,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.07,
                      maxWidth: screenWidth * 0.6,
                      minHeight: screenHeight * 0.04,
                      minWidth: screenWidth * 0.3,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Welcome to Techniche 2025",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                "Select a section to continue:",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Campus Ambassador Button
              _buildSectionButton(
                context: context,
                title: "Campus Ambassador",
                description: "Manage your CA profile and track your progress",
                icon: Icons.school,
                color: Colors.orange,
                onTap: () async {
                  try {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    // Check if user is authenticated
                    bool isAuthenticated =
                        await AuthController().isUserAuthenticated();

                    // Dismiss loading indicator
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (isAuthenticated) {
                      // Validate token and fetch latest user data
                      bool isValid = await AuthController()
                          .validateTokenAndFetchUser(context);
                      if (isValid) {
                        if (context.mounted) {
                          Navigator.pushNamed(context, BottomNavBar.routeName);
                        }
                      } else {
                        if (context.mounted) {
                          Navigator.pushNamed(context, AuthScreen.routeName);
                        }
                      }
                    } else {
                      // Navigate to auth screen
                      if (context.mounted) {
                        Navigator.pushNamed(context, AuthScreen.routeName);
                      }
                    }
                  } catch (e) {
                    // Handle any errors
                    print("Error navigating to CA portal: $e");
                    // Dismiss loading indicator if it's still showing
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Error accessing CA portal. Please try again.")),
                      );
                      // Navigate to auth as fallback
                      Navigator.pushNamed(context, AuthScreen.routeName);
                    }
                  }
                },
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              SizedBox(height: screenHeight * 0.03),

              // Guwahati Half Marathon Button
              _buildSectionButton(
                context: context,
                title: "Guwahati Half Marathon",
                description: "Track your steps and participate in the event",
                icon: Icons.directions_run,
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/ghm-screen', // You'll need to create this route
                  );
                },
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),

              SizedBox(height: screenHeight * 0.03),

              // Techniche Button
              _buildSectionButton(
                context: context,
                title: "Techniche",
                description: "Stay updated with the latest fest information",
                icon: Icons.celebration,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/techniche-screen', // You'll need to create this route
                  );
                },
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionButton({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.035),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: screenWidth * 0.08,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.006),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: screenWidth * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
