import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Homescreen extends StatelessWidget {
  static const String routeName = '/home-screen';
  const Homescreen({super.key});

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

  // Show FAQ dialog
  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                      child: const Text('Close'),
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

  // Show Contact Us dialog
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => _makePhoneCall('+919817337227'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Color(0xFFFF00F7),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raghav',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '+91 98173 37227',
                              style: TextStyle(
                                color: Colors.black54,
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Color(0xFFFF00F7),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sayantan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '+91 94371 16372',
                              style: TextStyle(
                                color: Colors.black54,
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
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build FAQ item
  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          // Check if user data is fully loaded
          if (user.name.isEmpty || user.email.isEmpty) {
            return _buildLoadingState(context);
          }

          // Display redesigned content when data is available
          return _buildContent(context, user);
        },
      ),
    );
  }

  // Modern, clean app bar
  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(MediaQuery.of(context).size.height * 0.075),
      child: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Campus Ambassador',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
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
              ];
            },
          ),
        ],
      ),
    );
  }

  // Loading state widget
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFFF00F7),
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () =>
                context.read<AuthController>().fetchUserData(context),
            child: const Text(
              'Retry Loading Data',
              style: TextStyle(
                color: Color(0xFFFF00F7),
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Main content with modern, minimalistic design
  // Replace the _buildContent method with this updated version:

  Widget _buildContent(BuildContext context, dynamic user) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      // Wrap with SingleChildScrollView
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Techniche Logo
            Center(
              child: Container(
                height: size.height * 0.12,
                width: size.width * 0.5,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo_withoutBG.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Welcome Section
            Text(
              'Welcome, ${user.name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: size.height * 0.015),

            // Welcome Paragraph Placeholder
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFFF00F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Techniche, IIT Guwahati's annual techno-management fest, is a hub for innovation and impact. Our CA Program connects students from 1000+ colleges, fostering skills in marketing, and event planning. As the backbone of Techniche, CAs play a crucial role in making the 27th edition a grand success!",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Slogan Placeholder
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(0xFFFF00F7).withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '• LEAD • INSPIRE • ELEVATE •',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF00F7),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // CA ID Card - Remove Expanded widget
            Container(
              padding: const EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 20), // Add margin at bottom
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF00F7).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Make sure column takes minimum size
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CAMPUS AMBASSADOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${user.points} POINTS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Replace Spacer with fixed height
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 40), // Replace Spacer with fixed height
                  Row(
                    children: [
                      const Text(
                        'UNIQUE CA ID:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.t_id,
                          style: const TextStyle(
                            color: Color(0xFF00FFF7), // neon cyan
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
