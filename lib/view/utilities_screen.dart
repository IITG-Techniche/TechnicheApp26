import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:techniche26/utils/animate_gradient_background.dart';

class UtilitiesScreen extends StatefulWidget {
  static const String routeName = '/utilities-screen';
  const UtilitiesScreen({Key? key}) : super(key: key);
 

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  bool showFAQ = false;
  
  final Color neonCyan = const Color(0xFF00FFFF);

  void _showContactsModal(String title, List<_Contact> contacts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...contacts.map((c) => _ContactListTile(contact: c)),
          ],
        ),
      ),
    );
  }

  void _openTeamCarousel() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const TeamCarouselScreen(),
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
    const List<_Contact> hospitalContacts = [
      _Contact(name: 'Emergency', number: '102'),
      _Contact(name: 'Hospital Reception', number: '+91-361-2582099'),
    ];
    const List<_Contact> transportContacts = [
      _Contact(name: 'E-Rickshaw 1', number: '+91-600-1440472'),
      _Contact(name: 'E-Rickshaw 2', number: '+91-789-6513761'),
      _Contact(name: 'E-Rickshaw 3', number: '+91-848-6664856'),
    ];
    const List<_Contact> hospitalityContacts = [
      _Contact(name: 'Hospitality Head (Uday)', number: '+91-90754-38210'),
      _Contact(name: 'Hospitality Head (Raghav)', number: '+91-98173-37227'),
      _Contact(name: 'Hospitality Head (Vibha)', number: '+91-92161-95181'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                        AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Utilities &  Contacts',
                      textStyle: GoogleFonts.orbitron(
                        color: neonCyan,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 80),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  totalRepeatCount: 1,
                  isRepeatingAnimation: false,
                  displayFullTextOnTap: true,
                  pause: const Duration(milliseconds: 500),
                ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ModalUtilityIcon(
                        icon: Icons.local_hospital,
                        label: 'IITG Hospital',
                        contacts: hospitalContacts,
                        onTap: () => _showContactsModal(
                            'IITG Hospital', hospitalContacts),
                      ),
                      _ModalUtilityIcon(
                        icon: Icons.local_shipping,
                        label: 'Transport',
                        contacts: transportContacts,
                        onTap: () =>
                            _showContactsModal('Transport', transportContacts),
                      ),
                      _ModalUtilityIcon(
                        icon: Icons.hotel,
                        label: 'Hospitality',
                        contacts: hospitalityContacts,
                        onTap: () => _showContactsModal(
                            'Hospitality', hospitalityContacts),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.people_alt),
                    title: const Text('Team'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TeamImageCarouselScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Developers'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openTeamCarousel,
                  ),
                  ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: const Text('FAQ'),
                    trailing:
                        Icon(showFAQ ? Icons.expand_less : Icons.expand_more),
                    onTap: () => setState(() => showFAQ = !showFAQ),
                  ),
                  if (showFAQ) ...[
                    const _FAQList(),
                    const Divider(),
                  ],

                  // Quick Links Section
                  const SizedBox(height: 18),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                    child: Text('Quick Links',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickLinkIcon(
                        assetIconPath: 'assets/instagram.png',
                        color: Colors.pinkAccent,
                        url:
                            'https://www.instagram.com/techniche_iitguwahati/?hl=en',
                        label: 'Instagram',
                      ),
                      _QuickLinkIcon(
                        assetIconPath: 'assets/linkedin.png',
                        color: Colors.blue,
                        url: 'https://in.linkedin.com/company/techniche-iitg',
                        label: 'LinkedIn',
                      ),
                      _QuickLinkIcon(
                        assetIconPath: 'assets/social-media.png',
                        color: Colors.lightBlue,
                        url: 'https://twitter.com/Techniche_IITG',
                        label: 'X.com',
                      ),
                      _QuickLinkIcon(
                        assetIconPath: 'assets/youtube.png',
                        color: Colors.red,
                        url: 'https://www.youtube.com/c/techniche',
                        label: 'YouTube',
                      ),
                      _QuickLinkIcon(
                        assetIconPath: 'assets/medium.png',
                        color: Colors.deepPurple,
                        url: 'https://media-techniche.medium.com/',
                        label: 'Medium',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Container(
              height: 25,
              color: const Color.fromARGB(255, 39, 39, 39), // dark grey
              child: const MarqueeText(
                text: 'Made with '
                    '❤'
                    ' by Techniche DevOps IITG',
                style: TextStyle(
                  color: Color.fromARGB(255, 84, 84, 84),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------- Helper widgets & models (top-level) -----------------

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
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot open $label')),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.13),
            ),
            child:
                Image.asset(assetIconPath, width: 32, height: 32, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

class _ModalUtilityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<_Contact> contacts;
  final VoidCallback onTap;

  const _ModalUtilityIcon({
    Key? key,
    required this.icon,
    required this.label,
    required this.contacts,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x1A448AFF), // blueAccent with opacity
            ),
            child: Icon(icon, size: 32, color: Colors.blueAccent),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final _Contact contact;
  const _ContactListTile({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.contact_phone),
      title: Text(contact.name),
      subtitle: Text(contact.number),
      trailing: IconButton(
        icon: const Icon(Icons.call),
        onPressed: () async {
          final Uri url = Uri.parse('tel:${contact.number}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot launch dialer')),
              );
            }
          }
        },
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
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final c = contacts[i];
          return ListTile(
            leading: const Icon(Icons.contact_phone),
            title: Text(c.name),
            subtitle: Text(c.number),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _callNumber(context, c.number),
            ),
          );
        },
      ),
    );
  }

  Future<void> _callNumber(BuildContext context, String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot launch dialer')));
      }
    }
  }
}

class _FAQList extends StatelessWidget {
  const _FAQList({Key? key}) : super(key: key);

  final List<_FAQ> faqs = const [
    _FAQ(
      question: 'How do I register for events?',
      answer:
          'Visit the official website or instagram profile of Techniche for all events registrations.',
    ),
    _FAQ(
      question: 'Where can I find the event schedule?',
      answer: 'The schedule is available under the Schedule tab.',
    ),
    _FAQ(
      question: 'Is accommodation provided?',
      answer:
          'Hostel accommodation is limited. Please contact Hospitality Team.',
    ),
    _FAQ(
      question: 'Who do I contact in case of emergency?',
      answer: 'Use the IITG Hospital quick contact above.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      itemCount: faqs.length,
      itemBuilder: (_, i) {
        final f = faqs[i];
        return ExpansionTile(
          title: Text(f.question),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(f.answer),
            )
          ],
        );
      },
    );
  }
}

/// ---------- Team Carousel Screen (retro-futuristic, halo aligned) ----------
class TeamCarouselScreen extends StatefulWidget {
  const TeamCarouselScreen({Key? key}) : super(key: key);

  @override
  State<TeamCarouselScreen> createState() => _TeamCarouselScreenState();
}

class _TeamCarouselScreenState extends State<TeamCarouselScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController =
      PageController(viewportFraction: 0.78, initialPage: 0);
  late AnimationController _ringController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  final List<_TeamMember> members = const [
    _TeamMember(
        name: 'Dhruv',
        role: 'DevOps Head',
        imageUrl: 'assets/dhruv-app.jpg',
        facts: [
          'Sees bugs as “feature opportunities”',
          'Kept servers alive in a storm'
        ]),
    _TeamMember(
        name: 'Arya',
        role: 'DevOps Head',
        imageUrl: 'assets/arya-app.jpg',
        facts: ['Builds backend magic', 'Coffee-fueled late nights']),
    _TeamMember(
        name: 'Ayush',
        role: 'Core Developer',
        imageUrl: 'assets/ayush-app.jpg',
        facts: ['Coding Wizard', 'ChatGPT is afraid of him']),
    _TeamMember(
        name: 'Divyansh',
        role: 'Developer (Organizer)',
        imageUrl: 'assets/divyansh-app.jpg',
        facts: ['Focus on integrations', 'Proud bug hunter']),
    _TeamMember(
        name: 'Kashish',
        role: 'Developer (Organizer)',
        imageUrl: 'assets/kashish-app.jpg',
        facts: ['Fixes problems on the spot', 'Turns ideas into experiments']),
  ];

  @override
  void initState() {
    super.initState();

    _ringController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();

    _resumeAutoPlay();
  }

  void _resumeAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (t) {
      final next = (_currentIndex + 1) % members.length;
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
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _openMemberDialog(_TeamMember m) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    m.imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 140,
                      height: 140,
                      color: Colors.grey[800],
                      child: const Icon(Icons.person,
                          size: 64, color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(m.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(m.role, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Divider(),
                ...m.facts.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              size: 18, color: Colors.cyanAccent),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f)),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.black)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _neonColor() => Colors.cyanAccent.shade200;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.88),
      body: SafeArea(
        child: Stack(
          children: [
            // faint gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.blueGrey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // scanlines overlay
            const IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.06,
                child: CustomPaint(
                  painter: ScanlinePainter(),
                  size: Size.infinite,
                ),
              ),
            ),

            // header & close
            Positioned(
              top: 18,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const SizedBox(width: 12),
                    Text('Meet the Developers',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ]),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Carousel center - AnimatedBuilder listens to PageController to avoid global setState on scroll
            Center(
              child: SizedBox(
                height: size.height * 0.68,
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
                        final double rotate = (i - page) * 0.06;
                        final double opacity = 1.0 - (delta * 0.45);

                        final m = members[i];

                        return Transform.translate(
                          offset: Offset(0, delta * 12),
                          child: Transform.rotate(
                            angle: rotate,
                            child: Opacity(
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
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.02),
                                            Colors.white.withOpacity(0.01)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(
                                          color: _neonColor().withOpacity(
                                              i == _currentIndex ? 0.45 : 0.12),
                                          width: i == _currentIndex ? 1.8 : 1.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 220,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // halo + avatar - small AnimatedBuilder for ring only
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  AnimatedBuilder(
                                                    animation: _ringController,
                                                    builder: (_, __) {
                                                      // subtle pulsing - small subtree only
                                                      final phase = Curves
                                                          .easeInOut
                                                          .transform(
                                                              _ringController
                                                                  .value);
                                                      final haloScale = 0.96 +
                                                          0.08 *
                                                              (0.5 +
                                                                  0.5 * phase);
                                                      final haloOpacity = 0.08 +
                                                          0.06 *
                                                              (1 -
                                                                  (phase - 0.5)
                                                                          .abs() *
                                                                      2);

                                                      return Transform.scale(
                                                        scale: haloScale,
                                                        child: Opacity(
                                                          opacity: haloOpacity *
                                                              (i == _currentIndex
                                                                  ? 1.0
                                                                  : 0.5),
                                                          child: Container(
                                                            width: 160,
                                                            height: 160,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient:
                                                                  RadialGradient(
                                                                colors: [
                                                                  Colors.cyanAccent
                                                                      .withOpacity(0.14 *
                                                                          (i == _currentIndex
                                                                              ? 1
                                                                              : 0.6)),
                                                                  Colors.cyanAccent
                                                                      .withOpacity(0.04 *
                                                                          (i == _currentIndex
                                                                              ? 1
                                                                              : 0.4)),
                                                                  Colors
                                                                      .transparent,
                                                                ],
                                                                stops: const [
                                                                  0.0,
                                                                  0.6,
                                                                  1.0
                                                                ],
                                                              ),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .cyanAccent
                                                                    .withOpacity(i ==
                                                                            _currentIndex
                                                                        ? 0.9
                                                                        : 0.2),
                                                                width: i ==
                                                                        _currentIndex
                                                                    ? 2.2
                                                                    : 0.9,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  ClipOval(
                                                    child: Image.asset(
                                                      m.imageUrl,
                                                      width: 140,
                                                      height: 140,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) =>
                                                          Container(
                                                        width: 140,
                                                        height: 140,
                                                        color: Colors.grey[800],
                                                        child: const Icon(
                                                            Icons.person,
                                                            size: 56,
                                                            color:
                                                                Colors.white24),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),
                                              Text(m.name,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 6),
                                              Text(m.role,
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                              const SizedBox(height: 8),
                                              Opacity(
                                                opacity: i == _currentIndex
                                                    ? 1.0
                                                    : 0.0,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20.0),
                                                  child: Text(
                                                      'Tap avatar for fun facts',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .cyanAccent
                                                              .withOpacity(0.9),
                                                          fontSize: 12)),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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

            // bottom dots + role hint
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(members.length, (i) {
                        final selected = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: selected ? 26 : 10,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected ? _neonColor() : Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    members[_currentIndex].role,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600),
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

/// Simple scanline painter reused for the retro look
class ScanlinePainter extends CustomPainter {
  const ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.6
      ..isAntiAlias = false;

    const double spacing = 5.5;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Lightweight model classes
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
  final List<String> facts;
  const _TeamMember(
      {required this.name,
      required this.role,
      required this.imageUrl,
      required this.facts});
}

/// Simple lightweight image carousel screen (13 members)
class TeamImageCarouselScreen extends StatelessWidget {
  const TeamImageCarouselScreen({Key? key}) : super(key: key);

  static final List<_TeamMemberSimple> teamMembers = [
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:
          Colors.black.withOpacity(0.88), // match developers background
      body: SafeArea(
        child: Stack(
          children: [
            // same faint gradient background as developers
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.blueGrey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // scanlines overlay
            const IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.06,
                child: CustomPaint(
                  painter: ScanlinePainter(),
                  size: Size.infinite,
                ),
              ),
            ),

            // 'Meet the Team' text at top left, close button at top right
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meet the Team',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white70, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            Center(
              child: SizedBox(
                height: size.height * 0.55,
                child: PageView.builder(
                  itemCount: teamMembers.length,
                  controller: PageController(viewportFraction: 0.82),
                  itemBuilder: (context, i) {
                    final m = teamMembers[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      child: Card(
                        color: Colors.blueGrey.shade800,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final url = Uri.parse(m.linkedinUrl);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Cannot open LinkedIn profile')),
                                    );
                                  }
                                }
                              },
                              child: ClipOval(
                                child: Container(
                                  width: 175,
                                  height: 175,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Image.asset(
                                      m.imageUrl,
                                      width: 175,
                                      height: 175,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(m.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(m.designation,
                                style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.link,
                                      color: Colors.cyanAccent, size: 28),
                                  tooltip: 'Open LinkedIn',
                                  onPressed: () async {
                                    final url = Uri.parse(m.linkedinUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Cannot open LinkedIn profile')),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'LinkedIn',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
