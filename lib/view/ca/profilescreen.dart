import 'package:amazon_clone/controller/provider_controller/user_provider.dart';
import 'package:amazon_clone/controller/authController.dart';
import 'package:amazon_clone/utils/errorHandler.dart';
// ignore: unused_import
import 'package:amazon_clone/model/userModel.dart'; // Import UserModel
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  // Function to refresh user data with updated points
  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the existing fetchUserData method from AuthController
      await AuthController().fetchUserData(context);

      // Optionally show a success message
      if (context.mounted) {
        showMessage(context, "Profile updated");
      }
    } catch (e) {
      print("Error refreshing user data: $e");
      // Show an error message to the user
      if (context.mounted) {
        showMessage(context, "Failed to update profile", isError: true);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value, double fontSize) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String points, double fontSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFF00F7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFFF00F7),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "",
                  style: TextStyle(
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
                      style: TextStyle(
                        fontSize: fontSize * 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _refreshUserData, // Refresh points on tap
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF00F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$points Points",
                              style: TextStyle(
                                fontSize: fontSize * 0.8,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _isLoading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, double fontSize) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Logout"),
                content: const Text("Are you sure you want to logout?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AuthController().logoutUser(context);
                    },
                    child: const Text("Logout"),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Logout",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.085),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFFF00F7),
            statusBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Color(0xFFFF00F7),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshUserData,
              tooltip: 'Refresh Profile',
            ),
          ],
          elevation: 0.0,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
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
