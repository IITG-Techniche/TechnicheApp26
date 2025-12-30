import 'package:flutter/material.dart';
import 'package:techniche26/view/ghm/ghm_selection.dart';
import 'package:techniche26/view/ghm/marathon_screen.dart';
import 'package:techniche26/view/techniche_screen.dart';
import 'package:techniche26/view/techno/papers_display.dart';
import 'package:techniche26/view/utilities_screen.dart';
import 'package:techniche26/view/workshops_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF181A20),
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.event,
                  title: 'Events',
                  routeName: EventsScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.work,
                  title: 'Workshops',
                  routeName: WorkshopsScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.article,
                  title: 'Technothlon PYQs',
                  routeName: TechnothlonScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.app_registration,
                  title: 'Techno Registration',
                  routeName: '/techno-registration',
                ),
                const Divider(color: Colors.white24, height: 2),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.directions_run,
                  title: 'GHM Selection',
                  routeName: GHMScreen.routeName,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.timer,
                  title: 'Marathon Tracker',
                  routeName: MarathonScreen.routeName,
                ),
                const Divider(color: Colors.white24, height: 2),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_bag,
                  title: 'Merchandise',
                  routeName: '/merch',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.schedule,
                  title: 'Schedule',
                  routeName: '/schedule',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.build,
                  title: 'Utilities',
                  routeName: UtilitiesScreen.routeName,
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
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF23242B),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Text(
            'TECHNICHE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(context, routeName);
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        '© Techniche 2026',
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 12,
        ),
      ),
    );
  }
}
