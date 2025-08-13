import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'landing_screen.dart' show AnimatedGradientBackground;

class UtilitiesScreen extends StatefulWidget {
  static const String routeName = '/utilities-screen';
  const UtilitiesScreen({Key? key}) : super(key: key);

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  bool showFAQ = false;
  bool showTeam = false;

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
      _Contact(name: 'Hospitality Head (Savi)', number: '+91-90090-49368'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Utilities & Contacts'),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Quick Contacts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
          ),
        ],
      ),
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
  const _ContactListTile({required this.contact});

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

/// ---------- Team Carousel Screen (retro-futuristic, halo aligned, particle burst) ----------
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
  double _page = 0.0;
  int _currentIndex = 0;

  // <-- FIX: initialize as an empty list (no 'late' keyword)
  List<GlobalKey<_ParticleBurstState>> _particleKeys = [];

  final List<_TeamMember> members = const [
    _TeamMember(
        name: 'Dhruv',
        role: 'Head Of DevOps',
        imageUrl: 'assets/dhruv-app.jpg',
        facts: [
          'Sees bugs as “feature opportunities”',
          'Kept servers alive in a storm'
        ]),
    _TeamMember(
        name: 'Arya',
        role: 'Head Of DevOps',
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

    // populate particle keys now that members is available
    _particleKeys =
        List.generate(members.length, (_) => GlobalKey<_ParticleBurstState>());

    _pageController.addListener(_onScroll);
    _ringController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();

    _resumeAutoPlay();
  }

  void _resumeAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (t) {
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

  void _onScroll() {
    if (!_pageController.hasClients) return;
    setState(() {
      _page = _pageController.page ?? _pageController.initialPage.toDouble();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.removeListener(_onScroll);
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset(m.imageUrl,
                      width: 140, height: 140, fit: BoxFit.cover),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _neonColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _neonColor().withOpacity(0.35), width: 1.2),
                      ),
                      child: Row(children: const [
                        Icon(Icons.rocket_launch,
                            size: 16, color: Colors.cyanAccent),
                        SizedBox(width: 8),
                        Text('Team',
                            style: TextStyle(color: Colors.cyanAccent)),
                      ]),
                    ),
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

            // Carousel center
            Center(
              child: SizedBox(
                height: size.height * 0.68,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: members.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, i) {
                    final delta = (i - _page).abs().clamp(0.0, 1.0);
                    final double scale = 1.0 - (delta * 0.15);
                    final double rotate = (i - _page) * 0.08;
                    final double opacity = 1.0 - (delta * 0.45);

                    final m = members[i];

                    return Transform.translate(
                      offset: Offset(0, delta * 18),
                      child: Transform.rotate(
                        angle: rotate,
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: GestureDetector(
                              onTap: () {
                                // guard: ensure particle key exists
                                if (i < _particleKeys.length) {
                                  _particleKeys[i].currentState?.burst();
                                  _pauseAutoPlay();
                                  Future.delayed(
                                      const Duration(milliseconds: 220), () {
                                    _openMemberDialog(m).then((_) {
                                      _resumeAutoPlay();
                                    });
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Card background
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.03),
                                            Colors.white.withOpacity(0.01)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(
                                          color: _neonColor().withOpacity(
                                              i == _currentIndex ? 0.55 : 0.14),
                                          width: i == _currentIndex ? 2.0 : 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _neonColor().withOpacity(
                                                i == _currentIndex
                                                    ? 0.12
                                                    : 0.04),
                                            blurRadius:
                                                i == _currentIndex ? 30 : 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Avatar + Halo (and particle burst)
                                    Center(
                                      child: SizedBox(
                                        width: 220,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                AnimatedBuilder(
                                                  animation: _ringController,
                                                  builder: (_, __) {
                                                    final double phase = Curves
                                                        .easeInOut
                                                        .transform(
                                                            _ringController
                                                                .value);
                                                    final double haloScale =
                                                        0.92 +
                                                            0.18 *
                                                                (0.5 +
                                                                    0.5 *
                                                                        phase);
                                                    final double haloOpacity = 0.12 +
                                                        0.08 *
                                                            (1 -
                                                                (phase - 0.5)
                                                                        .abs() *
                                                                    2);
                                                    final double thickness =
                                                        i == _currentIndex
                                                            ? 3.0
                                                            : 1.0;

                                                    return Transform.scale(
                                                      scale: haloScale,
                                                      child: Opacity(
                                                        opacity: haloOpacity *
                                                            (i == _currentIndex
                                                                ? 1.0
                                                                : 0.55),
                                                        child: Container(
                                                          width: 180,
                                                          height: 180,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            gradient:
                                                                RadialGradient(
                                                              colors: [
                                                                Colors
                                                                    .cyanAccent
                                                                    .withOpacity(0.18 *
                                                                        (i == _currentIndex
                                                                            ? 1
                                                                            : 0.6)),
                                                                Colors
                                                                    .cyanAccent
                                                                    .withOpacity(0.06 *
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
                                                            border: Border.all(
                                                              color: Colors
                                                                  .cyanAccent
                                                                  .withOpacity(
                                                                      i == _currentIndex
                                                                          ? 0.95
                                                                          : 0.22),
                                                              width: thickness,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),

                                                // Avatar
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    width: 160,
                                                    height: 160,
                                                    color: Colors.grey[900],
                                                    child: Image.asset(
                                                        m.imageUrl,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                                // Particle burst (key exists) - show above avatar
                                                if (i < _particleKeys.length)
                                                  ParticleBurst(
                                                      key: _particleKeys[i]),
                                              ],
                                            ),
                                            const SizedBox(height: 14),
                                            Text(m.name,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text(m.role,
                                                style: const TextStyle(
                                                    color: Colors.white70)),
                                            const SizedBox(height: 10),
                                            Opacity(
                                              opacity: i == _currentIndex
                                                  ? 1.0
                                                  : 0.0,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: Text(
                                                  'Tap avatar for fun facts',
                                                  style: TextStyle(
                                                      color: Colors.cyanAccent
                                                          .withOpacity(0.9),
                                                      fontSize: 12),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

/// Particle burst widget (small, lightweight emitter)
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({Key? key}) : super(key: key);

  @override
  _ParticleBurstState createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final int _count = 200;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _particles = [];
          _controller.reset();
          setState(() {});
        }
      });
    _particles = [];
  }

  void burst() {
    _particles = List.generate(_count, (_) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final speed = 120 + _rnd.nextDouble() * 120; // much larger spread
      final size = 8 + _rnd.nextDouble() * 10; // larger particles
      final color = _rnd.nextBool() ? Colors.cyanAccent : Colors.white;
      return _Particle(angle: angle, speed: speed, size: size, color: color);
    });
    _controller.forward(from: 0.0);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: true,
      child: SizedBox(
        width: 260,
        height: 260,
        child: CustomPaint(
          painter: _ParticlePainter(
              particles: _particles, progress: _controller.value),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  _Particle(
      {required this.angle,
      required this.speed,
      required this.size,
      required this.color});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Increase the spread and keep particles visible longer
    for (final p in particles) {
      final distance = p.speed *
          pow(progress, 0.7) *
          0.9; // more spread, less early clustering
      final dx = center.dx + cos(p.angle) * distance;
      final dy = center.dy + sin(p.angle) * distance;
      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = p.color.withOpacity(alpha);
      canvas.drawCircle(Offset(dx, dy), p.size * (1.0 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
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
  const _TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.facts,
  });
}
