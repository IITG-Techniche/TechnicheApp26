import 'package:techniche26/controller/provider_controller/user_provider.dart';
import 'package:techniche26/controller/authController.dart';
import 'package:techniche26/utils/errorHandler.dart';
// ignore: unused_import
import 'package:techniche26/model/userModel.dart'; // Import UserModel
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Theme Colors Inspired by Legacy Screen ---
  final Color neonMagenta = const Color(0xFFFF00F7);
  final Color neonCyan = const Color(0xFF00FFFF);
  final Color bgColor = const Color(0xFF0A0A0A);
  // --- End Theme Colors ---

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  // Function to refresh user data, logic remains the same
  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthController().fetchUserData(context);
      if (context.mounted) {
        showMessage(context, "Profile updated");
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(context, "Failed to update profile", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Themed widget to display a row of user information
  Widget _buildInfoRow(String label, String value, double fontSize) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: fontSize * 0.9,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Themed header widget with user name and points
  Widget _buildHeader(String name, String points, double fontSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonCyan.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: neonMagenta,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "",
              style: GoogleFonts.orbitron(
                fontSize: fontSize,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $name",
                  style: GoogleFonts.orbitron(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _refreshUserData,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$points Points",
                        style: GoogleFonts.orbitron(
                          fontSize: fontSize,
                          color: neonCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isLoading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Icon(
                          Icons.refresh,
                          color: neonCyan,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Themed logout button
  Widget _buildLogoutButton(BuildContext context, double fontSize) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.withOpacity(0.7)),
                ),
                title: Text("Logout",
                    style: GoogleFonts.orbitron(color: Colors.white)),
                content: Text("Are you sure you want to logout?",
                    style: GoogleFonts.orbitron(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel",
                        style: GoogleFonts.orbitron(color: Colors.white70)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AuthController().logoutUser(context);
                    },
                    child: Text("Logout",
                        style: GoogleFonts.orbitron(color: Colors.red)),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red),
          ),
          elevation: 0,
        ),
        child: Text(
          "Logout",
          style: GoogleFonts.orbitron(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: SizedBox(
          width: screenWidth * 0.4,
          child: Image.asset(
            'assets/logo_withoutBG.png',
            fit: BoxFit.contain,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshUserData,
            tooltip: 'Refresh Profile',
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        color: Colors.white,
        backgroundColor: bgColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user.name, user.points.toString(), fontSize),
                const SizedBox(height: 24),
                _buildInfoRow("CA ID", user.t_id, fontSize),
                _buildInfoRow("Email", user.email, fontSize),
                _buildInfoRow("Contact", user.contact.toString(), fontSize),
                _buildInfoRow("City", user.city, fontSize),
                _buildInfoRow("State", user.state, fontSize),
                _buildInfoRow("Institution", user.institution, fontSize),
                _buildLogoutButton(context, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
