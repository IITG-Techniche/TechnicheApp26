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
      backgroundColor: const Color(0xFFF7E8C9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.085),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFF7E8C9),
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: const Color(0xFFF7E8C9),
          flexibleSpace: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: constraints.maxHeight * 0.1,
                    horizontal: screenWidth * 0.05,
                  ),
                  child: Container(
                    width: screenWidth * 0.4, // Adjust logo width
                    child: Image.asset(
                      'assets/logo_withoutBG.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
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
              Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                    color: const Color(0xFF9E9C98),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Techniche 2025",
                style: TextStyle(
                  fontSize: screenWidth * 0.09,
                    color: const Color(0xFF0E1F48),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Select a section to continue:",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Guwahati Half Marathon Image Section
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/ghm-selection',
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.35, 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), 
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 0), 
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: Image.asset(
                              'assets/marathon_banner.png', 
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: screenHeight * 0.25, 
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                              children: [
                                Text(
                                  "Guwahati Half Marathon",
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "Track your steps and participate in the event",
                                  style: TextStyle(
                                    fontSize: 14, 
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Arrow indicator for marathon card
                      Positioned(
                        bottom: 50,
                        right: 15,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 28,
                          color: Colors.green.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Campus Ambassador and Techniche Buttons Side by Side
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
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
                      child: _buildBoxButton(
                        title: "Campus Ambassador",
                        description: "Manage your CA profile and track your progress",
                        imagePath: 'assets/ca_icon.png',  // Changed from icon to imagePath
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/techniche-screen',
                        );
                      },
                      child: _buildBoxButton(
                        title: "Techniche",
                        description: "Stay updated with the latest fest information",
                        imagePath: 'assets/techniche_events.png',  // Changed from icon to imagePath
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxButton({
    required String title,
    required String description,
    required String imagePath,  // Changed from IconData icon to String imagePath
    required Color color,
  }) {
    return Container(
      width: 190,
      height: 190,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E1F48),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0E1F48).withOpacity(0.38),
                ),
              ),
            ],
          ),
          // Arrow indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.arrow_forward,
              size: 18,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}