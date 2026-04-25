/// CA (Campus Ambassador) Profile Screen
library;
import 'package:techniche26/controller/riverpod_controller/ca_user_provider.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/utils/errorHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ca_header.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(caAuthControllerProvider).fetchUserData(context);
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(caUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F5),
      body: Column(
        children: [
          const CAHeader(title: "MY PROFILE"),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUserData,
              color: const Color(0xFF002B5B),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: [
                  _buildProfileCard(user),
                  const SizedBox(height: 24),
                  _buildSectionHeader('INSTITUTIONAL DETAILS'),
                  _buildInfoCard([
                    _InfoItem(Icons.school_rounded, 'Institution',
                        user.institution.isEmpty ? 'N/A' : user.institution),
                    _InfoItem(Icons.location_city_rounded, 'City',
                        user.city.isEmpty ? 'N/A' : user.city),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader('ACCOUNT OPTIONS'),
                  _buildActionCard(context),
                  const SizedBox(height: 32),
                ],
              ),
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
          child: const Center(
            child: Text(
              'MY PROFILE',
              style: TextStyle(
                color: Color(0XFF232930),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Univers',
                height: 1.2,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFF002B5B).withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontFamily: 'Univers',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B5B),
                  ),
                ),
              ),
              if (_isLoading)
                const Positioned(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF002B5B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            style: const TextStyle(
              fontFamily: 'Univers',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0XFF232930),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 14,
              color: const Color(0XFF232930).withOpacity(0.6),
            ),
          ),
          const Divider(height: 40, color: Color(0xFFF5F5F5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSimpleStat('CA ID', user.t_id),
              Container(width: 1, height: 30, color: const Color(0xFFE8E8E8)),
              _buildSimpleStat('POINTS', user.points.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Univers',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: const Color(0XFF232930).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Univers',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002B5B),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Univers',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Color(0xFF6D7985),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.value.icon,
                      size: 20, color: const Color(0xFF6D7985)),
                ),
                title: Text(
                  entry.value.label,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    color: const Color(0XFF232930).withOpacity(0.5),
                  ),
                ),
                subtitle: Text(
                  entry.value.value,
                  style: const TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0XFF232930),
                  ),
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64, color: Color(0xFFF5F5F5)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: ListTile(
        onTap: () => _showSignOutDialog(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout_rounded,
              size: 20, color: Colors.redAccent),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.redAccent,
          ),
        ),
        subtitle: const Text(
          'End current session',
          style: TextStyle(fontFamily: 'General Sans', fontSize: 12),
        ),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFE8E8E8)),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Sign Out",
              style: TextStyle(
                  fontFamily: 'Univers',
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF232930))),
          content: const Text("Are you sure you want to end your session?",
              style: TextStyle(
                  fontFamily: 'General Sans', color: Color(0xFF6D7985))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel",
                  style: TextStyle(
                      fontFamily: 'General Sans',
                      color: Color(0xFF6D7985),
                      fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(caAuthControllerProvider).logoutUser(context);
              },
              child: const Text("Sign Out",
                  style: TextStyle(
                      fontFamily: 'General Sans',
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE8E8E8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
