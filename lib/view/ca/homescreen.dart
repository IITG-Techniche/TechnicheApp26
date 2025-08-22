import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Homescreen extends StatelessWidget {
  static const String routeName = '/home-screen';
  const Homescreen({super.key});

  // --- Theme Colors Inspired by Legacy Screen ---
  final Color neonMagenta = const Color(0xFFFF00F7);
  final Color neonCyan = const Color(0xFF00FFFF);
  final Color bgColor = const Color(0xFF0A0A0A);
  // --- End Theme Colors ---

  // Function to launch phone dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  // Function to launch email
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Problem Report - Techniche CA Portal',
    );
    await launchUrl(launchUri);
  }

  // Show FAQ dialog (Themed)
  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgColor.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: neonCyan.withOpacity(0.7)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: neonCyan,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFAQItem(
                    question: 'What does it mean to be a College Ambassador?',
                    answer:
                        'As a College Ambassador, leverage the chance to showcase your college at Techniche, IIT Guwahati. Your role is key in connecting these two esteemed institutions and to be a part Techniche.',
                  ),
                  _buildFAQItem(
                    question:
                        'What are the responsibilities of a College Ambassador?',
                    answer:
                        'As a College Ambassador, your responsibilities will involve skill enhancement through social media management, trend analysis, event organisation, and various tasks. Additionally, you\'ll play a crucial role in hosting events and sessions on your campus, all under the umbrella of Techniche, IIT Guwahati.',
                  ),
                  _buildFAQItem(
                    question:
                        'How much time commitment is required for the CA role?',
                    answer:
                        'The time commitment varies, but it typically involves a few hours per week for promotion, organising events, and reporting on your progress.',
                  ),
                  _buildFAQItem(
                    question:
                        'Can I be a Campus Ambassador if I\'m not from a technical background?',
                    answer:
                        'Yes, Techniche values diversity, and you don\'t necessarily need a technical background. Passion for promoting and conducting technical events in your college and good skills are often key criteria.',
                  ),
                  _buildFAQItem(
                    question:
                        'How can I stay updated on Techniche events and announcements?',
                    answer:
                        'Follow Techniche\'s official website, social media accounts, and subscribe to newsletters for the latest updates and announcements.',
                  ),
                  _buildFAQItem(
                    question: 'Can CAs suggest ideas for improving events?',
                    answer:
                        'We welcome feedback and suggestions from ambassadors for enhancing the event experience.It\'s encouraged to share constructive ideas.',
                  ),
                  _buildFAQItem(
                    question: 'How will my progress be monitored?',
                    answer:
                        'You will upload proofs of your work on the CA portal; we will verify them and reward you with points that measure your progress. Please feel free to contact your mentors if you have any queries.',
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: GoogleFonts.orbitron(color: neonMagenta),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show Contact Us dialog (Themed)
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgColor.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: neonCyan.withOpacity(0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Contact Us',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: neonCyan,
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => _makePhoneCall('+919817337227'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: neonMagenta,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raghav',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '+91 98173 37227',
                              style: GoogleFonts.orbitron(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _makePhoneCall('+919437116372'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: neonMagenta,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sayantan',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '+91 94371 16372',
                              style: GoogleFonts.orbitron(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.orbitron(color: neonMagenta),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build FAQ item (Themed)
  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              height: 1.4,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // Set dark background
      appBar: _buildAppBar(context),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          if (user.name.isEmpty || user.email.isEmpty) {
            return _buildLoadingState(context);
          }
          return _buildContent(context, user);
        },
      ),
    );
  }

  // Themed App Bar
  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(MediaQuery.of(context).size.height * 0.075),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bgColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Campus Ambassador',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
          ),
        ),
         leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>  AuthController().logoutUser(context),
          ),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: bgColor.withOpacity(0.95),
                textStyle: GoogleFonts.orbitron(color: Colors.white70),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: neonCyan),
              onSelected: (value) {
                if (value == 'faq') {
                  _showFAQDialog(context);
                } else if (value == 'contact') {
                  _showContactDialog(context);
                } else if (value == 'report') {
                  _sendEmail('pr@technicheiitg.in');
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'faq',
                    child: Text('Frequently Asked Questions'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'contact',
                    child: Text('Contact Us'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Report a Problem'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  // Themed Loading state widget
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: neonCyan,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () =>
                context.read<AuthController>().fetchUserData(context),
            child: Text(
              'Retry Loading Data',
              style: GoogleFonts.orbitron(
                color: neonMagenta,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Main content with futuristic, neon design
  Widget _buildContent(BuildContext context, dynamic user) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(
            //   child: Container(
            //     height: size.height * 0.12,
            //     width: size.width * 0.5,
            //     decoration: const BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage('assets/logo_withoutBG.png'),
            //         fit: BoxFit.contain,
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Welcome, ${user.name}',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: neonCyan.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Techniche, IIT Guwahati's annual techno-management fest, is a hub for innovation and impact. Our CA Program connects students from 1000+ colleges, fostering skills in marketing, and event planning. As the backbone of Techniche, CAs play a crucial role in making the 27th edition a grand success!",
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: neonMagenta.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '• LEAD • INSPIRE • ELEVATE •',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    color: neonMagenta,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            // Themed CA ID Card
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                border: Border.all(color: neonMagenta, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: neonMagenta.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
                color: bgColor.withOpacity(0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CAMPUS AMBASSADOR',
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '${user.points} POINTS',
                        style: GoogleFonts.orbitron(
                          color: neonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.orbitron(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Text(
                        'UNIQUE CA ID:',
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        user.t_id,
                        style: GoogleFonts.orbitron(
                          color: neonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}