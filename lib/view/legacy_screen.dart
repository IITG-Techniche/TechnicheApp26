import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:techniche26/utils/animate_gradient_background.dart';

class LegacyPage extends StatefulWidget {
  const LegacyPage({Key? key}) : super(key: key);

  @override
  State<LegacyPage> createState() => _LegacyPageState();
}

class _LegacyPageState extends State<LegacyPage> with TickerProviderStateMixin {
  final Color neonBlue = const Color.fromARGB(255, 32, 72, 164);
  final Color neonCyan = const Color(0xFF00FFFF);
  final Color bgColor = const Color(0xFF0A0A0A);
  final Color successGreen = const Color(0xFF00E676);
  final Color goldAccent = const Color(0xFFFFD700);

  late List<AnimationController> _animationControllers;

  final List<Map<String, dynamic>> timelineData = [
    {
      "year": "1999",
      "event": "Journey of Techniche begins.",
      "icon": Icons.rocket_launch_rounded,
      "color": const Color(0xFF00E5FF),
    },
    {
      "year": "2009",
      "event": "First edition of Guwahati Half Marathon (GHM) is commenced.",
      "icon": Icons.directions_run_rounded,
      "color": const Color(0xFFFF6D00),
    },
    {
      "year": "2010",
      "event":
          "Technothlon achieves global reach, emerging as India's premier logic exam for students.",
      "icon": Icons.public_rounded,
      "color": const Color(0xFF7C4DFF),
    },
    {
      "year": "2017",
      "event":
          "Five neighbouring villages adopted under the Pragati Initiatives.",
      "icon": Icons.volunteer_activism_rounded,
      "color": const Color(0xFF00E676),
    },
    {
      "year": "2023",
      "event":
          "Techniche successfully completes 25 years, marking a silver milestone.",
      "icon": Icons.emoji_events_rounded,
      "color": const Color(0xFFFFD700),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      timelineData.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + (index * 150)),
      ),
    );

    // Staggered animation start
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Center align the animated text
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Where Innovation Meets Collaboration',
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
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "The Annual Techno-Management fest of IIT Guwahati,\nLargest in North-East India.",
                    style: GoogleFonts.orbitron(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 30),
                _buildTimeline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {"label": "Prizes Worth", "value": "₹20 Lakhs"},
      {"label": "Lives Impacted", "value": "1 Lakh+"},
      {"label": "Footfall", "value": "50K+"},
      {"label": "Growth", "value": "3x YoY"},
      {"label": "Meta Likes", "value": "150K+"},
    ];

    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: stats.map((stat) {
        return _neonCard(stat["label"]!, stat["value"]!);
      }).toList(),
    );
  }

  Widget _neonCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: neonBlue, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        color: bgColor.withOpacity(0.8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: neonCyan,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        // Title with glow effect
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                neonBlue.withOpacity(0.3),
                neonCyan.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: neonCyan.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: neonCyan.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            "Legacy Timeline",
            style: GoogleFonts.orbitron(
              color: neonCyan,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Timeline tiles
        Column(
          children: List.generate(timelineData.length, (index) {
            final data = timelineData[index];
            final Color tileColor = data["color"] as Color;
            final IconData tileIcon = data["icon"] as IconData;

            return AnimatedBuilder(
              animation: _animationControllers[index],
              builder: (context, child) {
                final t = Curves.easeOutBack
                    .transform(_animationControllers[index].value);
                final scale = 0.8 + 0.2 * t;
                final opacity = t.clamp(0.0, 1.0);
                final slideOffset = Offset(0, (1 - t) * 50);

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: slideOffset,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              child: TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.22,
                isFirst: index == 0,
                isLast: index == timelineData.length - 1,
                beforeLineStyle: LineStyle(
                  color: tileColor.withOpacity(0.6),
                  thickness: 3,
                ),
                afterLineStyle: LineStyle(
                  color: index < timelineData.length - 1
                      ? (timelineData[index + 1]["color"] as Color)
                          .withOpacity(0.6)
                      : tileColor.withOpacity(0.6),
                  thickness: 3,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 44,
                  height: 44,
                  indicator: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          tileColor,
                          tileColor.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tileColor.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      tileIcon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                startChild: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              tileColor.withOpacity(0.3),
                              tileColor.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: tileColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          data["year"]!,
                          style: GoogleFonts.orbitron(
                            color: tileColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                endChild: Container(
                  margin: const EdgeInsets.only(
                      left: 12, right: 8, top: 12, bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: tileColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tileColor.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["event"]!,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
