import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TechnicheScreen extends StatelessWidget {
  static const String routeName = '/techniche-screen';

  const TechnicheScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                "About Techniche",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 0.7,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Techniche is the annual techno-management festival of IIT Guwahati. It serves as a platform for students to showcase their technical and managerial skills through various events, workshops, and competitions.",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white.withOpacity(0.82),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              _buildSection(
                context,
                "Events",
                "Coming soon: Information about various technical events, competitions, and showcases at Techniche 2025.",
                Icons.event_note,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildSection(
                context,
                "Workshops",
                "Coming soon: Details about hands-on workshops and training sessions across various domains of technology.",
                Icons.build,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildSection(
                context,
                "Guest Lectures",
                "Coming soon: Information about guest lectures from industry experts and renowned personalities.",
                Icons.person,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildSection(
                context,
                "Schedule",
                "Coming soon: Day-wise breakdown of all activities planned during Techniche 2025.",
                Icons.schedule,
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23242B),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenWidth * 0.04,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                          color: Colors.blueAccent, width: 1.2),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, String description, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      margin: EdgeInsets.only(bottom: screenWidth * 0.01),
      decoration: BoxDecoration(
        color: const Color(0xFF23242B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blueAccent,
            size: screenWidth * 0.07,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
