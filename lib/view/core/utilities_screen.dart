import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:techniche26/widgets/app_drawer.dart';
import '../../constant/appTheme.dart';
import '../../providers/theme_provider.dart';

class UtilitiesScreen extends ConsumerStatefulWidget {
  static const String routeName = '/utilities-screen';
  const UtilitiesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends ConsumerState<UtilitiesScreen> {
  bool showFAQ = false;
  bool isLoading = true;

  List<_Contact> hospitalContacts = const [
    _Contact(name: 'Emergency', number: '102'),
    _Contact(name: 'Hospital Reception', number: '+91-361-2582099'),
  ];
  List<_Contact> transportContacts = const [
    _Contact(name: 'E-Rickshaw 1', number: '+91-600-1440472'),
    _Contact(name: 'E-Rickshaw 2', number: '+91-789-6513761'),
    _Contact(name: 'E-Rickshaw 3', number: '+91-848-6664856'),
  ];
  List<_Contact> hospitalityContacts = const [
    _Contact(name: 'Hospitality Head (Uday)', number: '+91-90754-38210'),
    _Contact(name: 'Hospitality Head (Raghav)', number: '+91-98173-37227'),
    _Contact(name: 'Hospitality Head (Vibha)', number: '+91-92161-95181'),
  ];
  List<_TeamMember> devTeamMembers = const [
    _TeamMember(
        name: 'Dhruv', role: 'DevOps Head', imageUrl: 'assets/dhruv-app.jpg'),
    _TeamMember(
        name: 'Arya', role: 'DevOps Head', imageUrl: 'assets/arya-app.jpg'),
    _TeamMember(
        name: 'Ayush',
        role: 'Core Developer',
        imageUrl: 'assets/ayush-app.jpg'),
    _TeamMember(
        name: 'Divyansh',
        role: 'Developer (Organizer)',
        imageUrl: 'assets/divyansh-app.jpg'),
  ];
  List<_TeamMemberSimple> heads = const [
    _TeamMemberSimple(
        name: 'Rachit Shah',
        designation: 'Convenor',
        imageUrl: 'assets/rachit-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/rachit-shah-b5a597255/'),
    _TeamMemberSimple(
        name: 'Divyanshu Tiwari',
        designation: 'Finance Head',
        imageUrl: 'assets/tiwari-app.jpeg',
        linkedinUrl: 'https://www.linkedin.com/in/divyanshu-tiwari-925556256/'),
    _TeamMemberSimple(
        name: 'Aditya Damani',
        designation: 'Marketing Head',
        imageUrl: 'assets/damani-app.jpeg',
        linkedinUrl: 'https://www.linkedin.com/in/aditya-damani-418302262/'),
    _TeamMemberSimple(
        name: 'Yashvardhan Jaiswal',
        designation: 'Marketing Head',
        imageUrl: 'assets/vardhan-app.jpeg',
        linkedinUrl: 'https://www.linkedin.com/in/yashvardhanjaiswal/'),
    _TeamMemberSimple(
        name: 'Aarav Chanani',
        designation: 'Events Head',
        imageUrl: 'assets/aarav-app.jpeg',
        linkedinUrl: 'https://www.linkedin.com/in/aarav-chanani218/'),
    _TeamMemberSimple(
        name: 'Puja Kumari',
        designation: 'Events Head',
        imageUrl: 'assets/puja-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/puja-kumari-544667260/'),
    _TeamMemberSimple(
        name: 'Veenas Jaiswal',
        designation: 'Events Head',
        imageUrl: 'assets/veenas-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/veenas-jaiswal-93ab70259/'),
    _TeamMemberSimple(
        name: 'Rushikesh Pinge',
        designation: 'Public Relations Head',
        imageUrl: 'assets/rushi-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/rushikesh-pinge-aa1b33268/'),
    _TeamMemberSimple(
        name: 'Aileen Jess',
        designation: 'Media & Branding Head',
        imageUrl: 'assets/aileen-app.png',
        linkedinUrl: 'https://www.linkedin.com/in/aileen-jess-1a018b369/'),
    _TeamMemberSimple(
        name: 'Sanskriti Verma',
        designation: 'Media & Branding Head',
        imageUrl: 'assets/sanskriti-app.jpeg',
        linkedinUrl: 'https://www.linkedin.com/in/sanskriti-verma-15781525b/'),
    _TeamMemberSimple(
        name: 'Arya Pandey',
        designation: 'Development Operations Head',
        imageUrl: 'assets/arya-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/arya-pandey-265204257/'),
    _TeamMemberSimple(
        name: 'Dhruv Gupta',
        designation: 'Development Operations Head',
        imageUrl: 'assets/dhruv-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/dhruvgupta21iitg/'),
    _TeamMemberSimple(
        name: 'Amol Satheesh',
        designation: 'Creatives Head',
        imageUrl: 'assets/amol-app.jpg',
        linkedinUrl: 'https://www.linkedin.com/in/amol-reach/'),
  ];
  List<_FAQ> faqs = const [
    _FAQ(
        question: 'How do I register for events?',
        answer:
            'Visit the official website or instagram profile of Techniche for all events registrations.'),
    _FAQ(
        question: 'Where can I find the event schedule?',
        answer: 'The schedule is available under the Schedule tab.'),
    _FAQ(
        question: 'Is accommodation provided?',
        answer:
            'Hostel accommodation is limited. Please contact Hospitality Team.'),
    _FAQ(
        question: 'Who do I contact in case of emergency?',
        answer: 'Use the IITG Hospital quick contact above.'),
  ];

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval:
            const Duration(seconds: 600), // Bypass cache instantly
      ));
      await rc.fetchAndActivate();
      final str = rc.getString('utilities_data');
      if (str.isNotEmpty) {
        final data = jsonDecode(str);
        hospitalContacts = (data['hospital_contacts'] as List? ?? [])
            .map((e) =>
                _Contact(name: e['name'] ?? '', number: e['number'] ?? ''))
            .toList();
        transportContacts = (data['transport_contacts'] as List? ?? [])
            .map((e) =>
                _Contact(name: e['name'] ?? '', number: e['number'] ?? ''))
            .toList();
        hospitalityContacts = (data['hospitality_contacts'] as List? ?? [])
            .map((e) =>
                _Contact(name: e['name'] ?? '', number: e['number'] ?? ''))
            .toList();
        devTeamMembers = (data['dev_team'] as List? ?? [])
            .map((e) => _TeamMember(
                name: e['name'] ?? '',
                role: e['role'] ?? '',
                imageUrl: e['imageUrl'] ?? ''))
            .toList();
        heads = (data['heads'] as List? ?? [])
            .map((e) => _TeamMemberSimple(
                name: e['name'] ?? '',
                designation: e['designation'] ?? '',
                imageUrl: e['imageUrl'] ?? '',
                linkedinUrl: e['linkedinUrl'] ?? ''))
            .toList();
        faqs = (data['faqs'] as List? ?? [])
            .map((e) =>
                _FAQ(question: e['question'] ?? '', answer: e['answer'] ?? ''))
            .toList();
      }
    } catch (e) {
      debugPrint("Remote config fetch error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showContactsModal(String title, List<_Contact> contacts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
            ),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontUnivers,
                    color: AppTheme.textMain)),
            const SizedBox(height: 16),
            ...contacts.map((c) => _ContactListTile(contact: c)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openTeamCarousel() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            TeamCarouselScreen(members: devTeamMembers),
        transitionsBuilder: (_, animation, __, child) {
          final t = Curves.easeInOut.transform(animation.value);
          return Transform.scale(
            scale: 0.98 + 0.02 * t,
            child: Opacity(opacity: t, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        drawer: const AppDrawer(),
        body: const Center(
            child: CircularProgressIndicator(color: Color(0xFF002B5B))),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Utilities & Contacts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ModalUtilityIcon(
                            icon: Icons.local_hospital_rounded,
                            label: 'Hospital',
                            color: const Color(0xFFE53935),
                            onTap: () => _showContactsModal(
                                'IITG Hospital', hospitalContacts),
                          ),
                          _ModalUtilityIcon(
                            icon: Icons.local_shipping_rounded,
                            label: 'Transport',
                            color: const Color(0xFF1E88E5),
                            onTap: () => _showContactsModal(
                                'Transport', transportContacts),
                          ),
                          _ModalUtilityIcon(
                            icon: Icons.hotel_rounded,
                            label: 'Hospitality',
                            color: const Color(0xFF43A047),
                            onTap: () => _showContactsModal(
                                'Hospitality', hospitalityContacts),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildThemeTile(),
                      _buildSectionTile(
                        icon: Icons.people_alt_rounded,
                        title: 'Meet the Team',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TeamImageCarouselScreen(teamMembers: heads),
                          ),
                        ),
                      ),
                      _buildSectionTile(
                        icon: Icons.code_rounded,
                        title: 'App Developers',
                        onTap: _openTeamCarousel,
                      ),
                      _buildSectionTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Frequently Asked Questions',
                        trailing: Icon(
                          showFAQ
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF6D7985),
                        ),
                        onTap: () => setState(() => showFAQ = !showFAQ),
                      ),
                      if (showFAQ) ...[
                        _FAQList(faqs: faqs),
                        // const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 10),
                      const Text(
                        'Quick Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickLinkIcon(
                              assetIconPath: 'assets/instagram.png',
                              color: const Color(0xFFE4405F),
                              url:
                                  'https://www.instagram.com/techniche_iitguwahati/?hl=en',
                              label: 'Instagram',
                            ),
                            const SizedBox(width: 20),
                            _QuickLinkIcon(
                              assetIconPath: 'assets/linkedin.png',
                              color: const Color(0xFF0077B5),
                              url:
                                  'https://in.linkedin.com/company/techniche-iitg',
                              label: 'LinkedIn',
                            ),
                            const SizedBox(width: 20),
                            _QuickLinkIcon(
                              assetIconPath: 'assets/x.png',
                              color: const Color(0xFF1DA1F2),
                              url: 'https://twitter.com/Techniche_IITG',
                              label: 'X.com',
                            ),
                            const SizedBox(width: 20),
                            _QuickLinkIcon(
                              assetIconPath: 'assets/youtube.png',
                              color: const Color(0xFFFF0000),
                              url: 'https://www.youtube.com/c/techniche',
                              label: 'YouTube',
                            ),
                            const SizedBox(width: 20),
                            _QuickLinkIcon(
                              assetIconPath: 'assets/facebook.png',
                              color: const Color(0xFF1877F2),
                              url:
                                  'https://www.facebook.com/techniche.iitguwahati/',
                              label: 'Facebook',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 65,
            padding: const EdgeInsets.only(bottom: 35),
            width: double.infinity,
            color: AppTheme.backgroundGray,
            alignment: Alignment.center,
            child: const MarqueeText(
              text: 'Made with ❤️ by Techniche DevOps IITG • ',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: AppTheme.fontGeneralSans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile() {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE1EBFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDark ? Colors.amberAccent : const Color(0xFF002B5B),
            size: 24,
          ),
        ),
        title: Text(
          isDark ? 'Dark Theme' : 'Light Theme',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontGeneralSans,
            color: AppTheme.textMain,
          ),
        ),
        subtitle: Text(
          isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: AppTheme.fontGeneralSans,
            color: Color(0xFF6D7985),
          ),
        ),
        trailing: Switch.adaptive(
          value: isDark,
          activeColor: const Color(0xFF002B5B),
          onChanged: (_) {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
        ),
        onTap: () {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
      ),
    );
  }

  Widget _buildSectionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE1EBFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF002B5B), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontGeneralSans,
            height: 1.2,
            color: AppTheme.textMain,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6D7985)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFAFAFAF),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(
                    builder: (BuildContext innerContext) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(innerContext).openDrawer();
                        },
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            'assets/ghm/menu.png',
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 24.0,
                    child: Image.asset(
                      'assets/ghm/logo3.png',
                      fit: BoxFit.contain,
                    ),
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

class _QuickLinkIcon extends StatelessWidget {
  final String assetIconPath;
  final Color color;
  final String url;
  final String label;
  const _QuickLinkIcon({
    required this.assetIconPath,
    required this.color,
    required this.url,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(30),
          child:
              Image.asset(assetIconPath, width: 38, height: 38, color: color),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontGeneralSans,
            )),
      ],
    );
  }
}

class _ModalUtilityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ModalUtilityIcon({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.textMain,
            fontFamily: AppTheme.fontGeneralSans,
          ),
        ),
      ],
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final _Contact contact;
  const _ContactListTile({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFE1EBFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.phone_rounded,
              color: Color(0xFF002B5B), size: 22),
        ),
        title: Text(contact.name,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: AppTheme.fontGeneralSans,
                color: AppTheme.textMain)),
        subtitle: Text(contact.number,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontFamily: AppTheme.fontGeneralSans)),
        trailing: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_rounded,
                color: Color(0xFF43A047), size: 18),
          ),
          onPressed: () async {
            final Uri url = Uri.parse('tel:${contact.number}');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
        ),
      ),
    );
  }
}

class ContactsScreen extends StatelessWidget {
  final String title;
  final List<_Contact> contacts;
  const ContactsScreen({required this.title, required this.contacts, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                fontFamily: AppTheme.fontUnivers, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textMain,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          return _ContactListTile(contact: contacts[i]);
        },
      ),
    );
  }
}

class _FAQList extends StatelessWidget {
  final List<_FAQ> faqs;
  const _FAQList({Key? key, required this.faqs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: faqs.length,
      itemBuilder: (_, i) {
        final f = faqs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8).withOpacity(0.5)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                f.question,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: AppTheme.fontGeneralSans,
                    color: AppTheme.textMain),
              ),
              iconColor: const Color(0xFF002B5B),
              collapsedIconColor: const Color(0xFF6D7985),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    f.answer,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontFamily: AppTheme.fontGeneralSans,
                        height: 1.4),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class TeamCarouselScreen extends StatefulWidget {
  final List<_TeamMember> members;
  const TeamCarouselScreen({Key? key, required this.members}) : super(key: key);

  @override
  State<TeamCarouselScreen> createState() => _TeamCarouselScreenState();
}

class _TeamCarouselScreenState extends State<TeamCarouselScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController =
      PageController(viewportFraction: 0.78, initialPage: 0);
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  late final List<_TeamMember> members = widget.members;

  @override
  void initState() {
    super.initState();
    _resumeAutoPlay();
  }

  void _resumeAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      final next = (_currentIndex + 1) % members.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
        setState(() => _currentIndex = next);
      }
    });
  }

  void _pauseAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openMemberDialog(_TeamMember m) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE1EBFF),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: m.imageUrl.startsWith('http')
                        ? Image.network(
                            m.imageUrl,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 130,
                              height: 130,
                              color: Colors.grey[200],
                              child: const Icon(Icons.person,
                                  size: 64, color: Color(0xFF6D7985)),
                            ),
                          )
                        : Image.asset(
                            m.imageUrl,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 130,
                              height: 130,
                              color: Colors.grey[200],
                              child: const Icon(Icons.person,
                                  size: 64, color: Color(0xFF6D7985)),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(m.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontUnivers,
                        color: AppTheme.textMain)),
                const SizedBox(height: 4),
                Text(m.role,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppTheme.fontGeneralSans)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 18,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Meet the Developers',
                      style: TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 20,
                          fontFamily: AppTheme.fontUnivers,
                          fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF6D7985), size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                height: size.height * 0.62,
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, _) {
                    final page = _pageController.hasClients &&
                            _pageController.page != null
                        ? _pageController.page!
                        : _pageController.initialPage.toDouble();

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: members.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, i) {
                        final delta = (i - page).abs().clamp(0.0, 1.0);
                        final double scale = 1.0 - (delta * 0.12);
                        final double opacity = 1.0 - (delta * 0.4);

                        final m = members[i];

                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: GestureDetector(
                              onTap: () {
                                _pauseAutoPlay();
                                _openMemberDialog(m)
                                    .then((_) => _resumeAutoPlay());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: i == _currentIndex
                                          ? const Color(0xFF002B5B)
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: i == _currentIndex
                                              ? const Color(0xFFE1EBFF)
                                              : Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: m.imageUrl.startsWith('http')
                                              ? Image.network(
                                                  m.imageUrl,
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      Container(
                                                    width: 150,
                                                    height: 150,
                                                    color: Colors.white,
                                                    child: const Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color:
                                                            Color(0xFF6D7985)),
                                                  ),
                                                )
                                              : Image.asset(
                                                  m.imageUrl,
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      Container(
                                                    width: 150,
                                                    height: 150,
                                                    color: Colors.white,
                                                    child: const Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color:
                                                            Color(0xFF6D7985)),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(m.name,
                                          style: const TextStyle(
                                              color: Color(0XFF232930),
                                              fontSize: 20,
                                              fontFamily: 'Univers',
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(m.role,
                                          style: const TextStyle(
                                              color: Color(0xFF6D7985),
                                              fontFamily: 'General Sans',
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(members.length, (i) {
                  final selected = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF002B5B)
                          : const Color(0xFFD1D1D1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contact {
  final String name;
  final String number;
  const _Contact({required this.name, required this.number});
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}

class _TeamMember {
  final String name;
  final String role;
  final String imageUrl;
  const _TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}

class TeamImageCarouselScreen extends StatefulWidget {
  final List<_TeamMemberSimple> teamMembers;
  const TeamImageCarouselScreen({Key? key, required this.teamMembers})
      : super(key: key);

  @override
  State<TeamImageCarouselScreen> createState() =>
      _TeamImageCarouselScreenState();
}

class _TeamImageCarouselScreenState extends State<TeamImageCarouselScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.82);
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _resumeAutoPlay();
  }

  void _resumeAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (widget.teamMembers.isEmpty) return;
      final next = (_currentIndex + 1) % widget.teamMembers.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut);
        setState(() => _currentIndex = next);
      }
    });
  }

  void _pauseAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meet the Team',
                    style: TextStyle(
                      color: Color(0XFF232930),
                      fontSize: 20,
                      fontFamily: 'Univers',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF6D7985), size: 24),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                height: size.height * 0.6,
                child: PageView.builder(
                  itemCount: widget.teamMembers.length,
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, i) {
                    final m = widget.teamMembers[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: GestureDetector(
                        onTapDown: (_) => _pauseAutoPlay(),
                        onTapUp: (_) => _resumeAutoPlay(),
                        onTapCancel: () => _resumeAutoPlay(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE1EBFF),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: m.imageUrl.startsWith('http')
                                        ? Image.network(
                                            m.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(
                                              Icons.person,
                                              size: 80,
                                              color: Color(0xFF6D7985),
                                            ),
                                          )
                                        : Image.asset(
                                            m.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(
                                              Icons.person,
                                              size: 80,
                                              color: Color(0xFF6D7985),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(m.name,
                                  style: const TextStyle(
                                      color: Color(0XFF232930),
                                      fontSize: 22,
                                      fontFamily: 'Univers',
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(m.designation,
                                  style: const TextStyle(
                                      color: Color(0xFF6D7985),
                                      fontSize: 16,
                                      fontFamily: 'General Sans',
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse(m.linkedinUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.link_rounded, size: 18),
                                label: const Text('LinkedIn'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE1EBFF),
                                  foregroundColor: const Color(0xFF002B5B),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.teamMembers.length, (i) {
                  final selected = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF002B5B)
                          : const Color(0xFFD1D1D1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberSimple {
  final String name;
  final String designation;
  final String imageUrl;
  final String linkedinUrl;
  const _TeamMemberSimple({
    required this.name,
    required this.designation,
    required this.imageUrl,
    required this.linkedinUrl,
  });
}

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  double textWidth = 0.0;
  double? spacerWidth;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          textWidth = renderBox.size.width;
          spacerWidth = MediaQuery.of(context).size.width;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (spacerWidth == null) {
      return Text(
        widget.text,
        key: _textKey,
        style: widget.style,
      );
    }

    final totalWidth = textWidth + spacerWidth!;
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final animationValue = _controller.value;
          final offsetX = -((animationValue * totalWidth) % totalWidth);
          return Stack(
            children: [
              Positioned(
                left: offsetX,
                top: 0,
                child: IntrinsicWidth(
                  child: Text(widget.text, style: widget.style),
                ),
              ),
              Positioned(
                left: offsetX + totalWidth,
                top: 0,
                child: IntrinsicWidth(
                  child: Text(widget.text, style: widget.style),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
