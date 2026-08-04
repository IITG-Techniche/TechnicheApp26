import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/providers/navigation_provider.dart';
import 'package:techniche26/view/marathon/marathon_main.dart';
import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/view/events/events_screen.dart';
import 'package:techniche26/view/techno/papers_display.dart';
import 'package:techniche26/view/core/utilities_screen.dart';
import 'package:techniche26/view/events/workshops_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.white,
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
                _buildSectionTitle('Fest Events'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.event_note_rounded,
                  title: 'Events',
                  routeName: EventsScreen.routeName,
                  isTab: true,
                  tabIndex: 0,
                  ref: ref,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.build_circle_rounded,
                  title: 'Workshops',
                  routeName: WorkshopsScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.quiz_rounded,
                  title: 'Technothlon PYQs',
                  routeName: TechnothlonPyqScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.how_to_reg_rounded,
                  title: 'Techno Registration',
                  routeName: '/techno-registration',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: Color(0xFFE8E8E8), height: 1),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.school_rounded,
                  title: 'Campus Ambassador',
                  routeName: CaAuthScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  routeName: '/profile',
                ),
                // _buildDrawerItem(
                //   context: context,
                //   icon: Icons.directions_run_rounded,
                //   title: 'Marathon Practice',
                //   routeName: MarathonMainScreen.routeName,
                // ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: Color(0xFFE8E8E8), height: 1),
                ),
                _buildSectionTitle('More'),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Merchandise',
                  routeName: '/merch',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_suggest_rounded,
                  title: 'Utilities',
                  routeName: UtilitiesScreen.routeName,
                  isTab: true,
                  tabIndex: 4,
                  ref: ref,
                ),
              ],
            ),
          ),
          _buildFooter(),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.black.withOpacity(0.4),
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
    bool isTab = false,
    int? tabIndex,
    WidgetRef? ref,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF002B5B), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0XFF232930),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Univers',
            height: 1.2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        hoverColor: const Color(0xFFF5F5F5),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          if (isTab && tabIndex != null && ref != null) {
            ref.read(bottomNavSelectedIndexProvider.notifier).state = tabIndex;
            // Pop until we are back on LandingScreen to see the tab switch
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IIT Guwahati',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
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
              color: Colors.black.withOpacity(0.4),
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
