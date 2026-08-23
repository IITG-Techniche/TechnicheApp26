import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/providers/navigation_provider.dart';
import 'package:techniche26/providers/theme_provider.dart';
import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/view/events/events_screen.dart';
import 'package:techniche26/view/events/workshops_screen.dart';
import 'package:techniche26/view/team/app_dev_team_screen.dart';
import 'package:techniche26/view/team/heads_team_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _showMeetTheTeamModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Meet the Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Univers',
                  color: isDark ? Colors.white : const Color(0XFF232930),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a team category to explore credits and profiles',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'General Sans',
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985),
                ),
              ),
              const SizedBox(height: 18),

              // 1. Heads
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Heads',
                    style: TextStyle(
                      fontFamily: 'Univers',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0XFF232930),
                    ),
                  ),
                  subtitle: Text(
                    'Convenor & Module Heads of Techniche',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Close drawer as well
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HeadsTeamScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 2. App Developer
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'App Developer',
                    style: TextStyle(
                      fontFamily: 'Univers',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0XFF232930),
                    ),
                  ),
                  subtitle: Text(
                    'Core App Developers & DevOps team',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Close drawer as well
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppDevTeamScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final dividerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8);
    final textMain = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : Colors.black.withOpacity(0.4);

    return Drawer(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionTitle('Fest Events', textSecondary),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.event_note_rounded,
                  title: 'Events',
                  routeName: EventsScreen.routeName,
                  isTab: true,
                  tabIndex: 0,
                  ref: ref,
                  textMain: textMain,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.build_circle_rounded,
                  title: 'Workshops',
                  routeName: WorkshopsScreen.routeName,
                  textMain: textMain,
                  isDark: isDark,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor, height: 1),
                ),

                _buildSectionTitle('Campus & Preferences', textSecondary),

                // 1. Campus Ambassador
                _buildDrawerItem(
                  context: context,
                  icon: Icons.school_rounded,
                  title: 'Campus Ambassador',
                  routeName: CaAuthScreen.routeName,
                  textMain: textMain,
                  isDark: isDark,
                ),

                // 2. Bright/Dark Mode Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                      size: 22,
                    ),
                    title: Text(
                      isDark ? 'Dark Mode' : 'Bright Mode',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Univers',
                        height: 1.2,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeColor: const Color(0xFF38BDF8),
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    dense: true,
                  ),
                ),

                // 3. Meet the Team (Opens modal with Heads & App Developer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      Icons.groups_rounded,
                      color: isDark ? const Color(0xFF818CF8) : const Color(0xFF002B5B),
                      size: 22,
                    ),
                    title: Text(
                      'Meet the Team',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Univers',
                        height: 1.2,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    dense: true,
                    hoverColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F5),
                    onTap: () {
                      _showMeetTheTeamModal(context, isDark);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor, height: 1),
                ),

                _buildSectionTitle('More', textSecondary),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  routeName: '/profile',
                  textMain: textMain,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Merchandise',
                  routeName: '/merch',
                  textMain: textMain,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Image.asset(
              'assets/white_logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enriching Minds, Inspiring Innovation',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontFamily: 'General Sans',
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeName,
    required Color textMain,
    required bool isDark,
    bool isTab = false,
    int? tabIndex,
    WidgetRef? ref,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF002B5B),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textMain,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Univers',
            height: 1.2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        hoverColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F5),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          if (isTab && tabIndex != null && ref != null) {
            ref.read(bottomNavSelectedIndexProvider.notifier).state = tabIndex;
            Navigator.popUntil(context, (route) {
              return route.settings.name == '/landing-screen' || route.isFirst;
            });
          } else {
            Navigator.pushNamed(context, routeName);
          }
        },
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IIT Guwahati',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Univers',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© Techniche 2026',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.black.withOpacity(0.4),
              fontSize: 12,
              fontFamily: 'General Sans',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
