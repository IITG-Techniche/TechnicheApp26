/// CA (Campus Ambassador) Home Screen
library;

import 'package:techniche26/controller/riverpod_controller/ca_user_provider.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:techniche26/view/ca/ca_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homescreen extends ConsumerStatefulWidget {
  static const String routeName = '/home-screen';
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  @override
  void initState() {
    super.initState();
    // Trigger background data sync immediately on entry
    Future.microtask(() {
      if (mounted) {
        ref.read(caAuthControllerProvider).fetchUserData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(caUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F5),
      body: Column(
        children: [
          const CAHeader(title: 'CA DASHBOARD'),
          Expanded(
            child: user.name.isEmpty || user.email.isEmpty
                ? _buildLoadingState()
                : _buildContent(user),
          ),
        ],
      ),
    );
  }

  // Themed Loading state widget
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF002B5B),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Syncing Ambassador Data...',
            style: TextStyle(
              fontFamily: 'General Sans',
              color: const Color(0XFF232930).withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                ref.read(caAuthControllerProvider).fetchUserData(context),
            child: const Text(
              'Retry Connection',
              style: TextStyle(
                fontFamily: 'General Sans',
                color: Color(0xFF002B5B),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Main content with GHM-style cards
  Widget _buildContent(dynamic user) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Welcome Card
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002B5B).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      color: Color(0xFF002B5B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            color: const Color(0XFF232930).withOpacity(0.6),
                          ),
                        ),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontFamily: 'Univers',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF232930),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Techniche's CA Program connects students from 1000+ colleges, fostering skills in marketing, and event planning. You are the backbone of our 27th edition!",
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0XFF232930).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'POINTS',
                user.points.toString(),
                Icons.stars_rounded,
                const Color(0xFF002B5B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'CA ID',
                user.t_id,
                Icons.badge_rounded,
                const Color(0xFF6D7985),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Description Card
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: const Text(
                  '• LEAD • INSPIRE • ELEVATE •',
                  style: TextStyle(
                    fontFamily: 'Univers',
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF002B5B),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconLabel(Icons.rocket_launch_rounded, 'Innovation'),
                  _IconLabel(Icons.people_alt_rounded, 'Impact'),
                  _IconLabel(Icons.emoji_events_rounded, 'Success'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color accentColor) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 12),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Univers',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
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

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6D7985), size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'General Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6D7985),
            ),
          ),
        ],
      ),
    );
  }
}
