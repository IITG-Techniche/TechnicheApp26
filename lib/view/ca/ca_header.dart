import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class CAHeader extends ConsumerWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  const CAHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
  });

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Problem Report - Techniche CA Portal',
    );
    await launchUrl(launchUri);
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE8E8E8)),
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
                      fontFamily: 'Univers',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B5B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFAQItem(
                    'What does it mean to be a College Ambassador?',
                    'As a College Ambassador, leverage the chance to showcase your college at Techniche, IIT Guwahati. Your role is key in connecting these two esteemed institutions.',
                  ),
                  _buildFAQItem(
                    'What are the responsibilities?',
                    'Your responsibilities involve skill enhancement through social media, trend analysis, event organization, and hosting sessions on your campus.',
                  ),
                  _buildFAQItem(
                    'Time commitment?',
                    'Typically involves a few hours per week for promotion and reporting progress.',
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            fontFamily: 'General Sans',
                            color: Color(0xFF6D7985),
                            fontWeight: FontWeight.w600),
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

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontFamily: 'General Sans', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0XFF232930))),
          const SizedBox(height: 6),
          Text(answer, style: TextStyle(fontFamily: 'General Sans', fontSize: 14, height: 1.4, color: const Color(0XFF232930).withOpacity(0.7))),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE8E8E8))),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Contact Us', style: TextStyle(fontFamily: 'Univers', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF002B5B))),
                const SizedBox(height: 24),
                _contactItem('Raghav', '+91 98173 37227'),
                _contactItem('Sayantan', '+91 94371 16372'),
                const SizedBox(height: 20),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(fontFamily: 'General Sans', color: Color(0xFF6D7985), fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _contactItem(String name, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.phone_android_rounded, color: Color(0xFF002B5B)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontFamily: 'General Sans', fontWeight: FontWeight.bold, color: Color(0XFF232930))),
              Text(phone, style: TextStyle(fontFamily: 'General Sans', color: const Color(0XFF232930).withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15), 
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: onBack ?? () {
                    Navigator.pushNamedAndRemoveUntil(context, '/landing-screen', (route) => false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6D7985), size: 20),
                  ),
                )
              else
                const SizedBox(width: 32),
              const Spacer(flex: 1),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0XFF232930),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Univers',
                  height: 1.2,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(flex: 1),
              _buildMenu(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
          child: const Icon(Icons.more_vert_rounded, color: Color(0xFF6D7985), size: 20),
        ),
        onSelected: (value) {
          if (value == 'faq') _showFAQDialog(context);
          if (value == 'contact') _showContactDialog(context);
          if (value == 'report') _sendEmail('pr@technicheiitg.in');
          if (value == 'signout') _showSignOutDialog(context, ref);
        },
        itemBuilder: (BuildContext context) => [
          _popupItem('faq', Icons.help_outline_rounded, 'FAQ'),
          _popupItem('contact', Icons.contact_support_outlined, 'Contact'),
          _popupItem('report', Icons.bug_report_outlined, 'Report'),
          const PopupMenuDivider(),
          _popupItem('signout', Icons.logout_rounded, 'Sign Out', isDestructive: true),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupItem(String value, IconData icon, String text, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDestructive ? Colors.redAccent : const Color(0xFF6D7985)),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontFamily: 'General Sans', color: isDestructive ? Colors.redAccent : const Color(0XFF232930), fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500)),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Sign Out", style: TextStyle(fontFamily: 'Univers', fontWeight: FontWeight.bold, color: Color(0XFF232930))),
          content: const Text("Are you sure you want to sign out?", style: TextStyle(fontFamily: 'General Sans', color: Color(0xFF6D7985))),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel", style: TextStyle(fontFamily: 'General Sans', color: Color(0xFF6D7985), fontWeight: FontWeight.w600))),
            TextButton(onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(caAuthControllerProvider).logoutUser(context);
            }, child: const Text("Sign Out", style: TextStyle(fontFamily: 'General Sans', color: Colors.redAccent, fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
  }
}
