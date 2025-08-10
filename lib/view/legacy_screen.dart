import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'landing_screen.dart' show AnimatedGradientBackground;

class LegacyPage extends StatelessWidget {
  final Color neonPink = const Color.fromARGB(255, 32, 72, 164);
  final Color neonCyan = const Color(0xFF00FFFF);
  final Color bgColor = const Color(0xFF0A0A0A);

  final List<Map<String, String>> timelineData = [
    {"year": "1999", "event": "Journey of Techniche begins."},
    {
      "year": "2009",
      "event": "First edition of Guwahati Half Marathon (GHM) is commenced."
    },
    {
      "year": "2010",
      "event":
          "Technothlon achieves global reach, emerging as India's premier logic exam for students."
    },
    {
      "year": "2017",
      "event":
          "Five neighbouring villages adopted under the Pragati Initiatives."
    },
    {
      "year": "2023",
      "event":
          "Techniche successfully completes 25 years, marking a silver milestone."
    },
  ];

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
        border: Border.all(color: neonPink, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: neonPink.withOpacity(0.6),
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
        Text(
          "Legacy Timeline",
          style: GoogleFonts.orbitron(
            color: neonPink,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(timelineData.length, (index) {
            final data = timelineData[index];
            // Use a consistent lineXY and padding for all tiles to keep the bar straight
            double lineXY = 0.2;
            EdgeInsets startPad = const EdgeInsets.all(8.0);
            EdgeInsets endPad = const EdgeInsets.all(12.0);
            return TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: lineXY,
              isFirst: index == 0,
              isLast: index == timelineData.length - 1,
              beforeLineStyle: LineStyle(
                color: neonCyan,
                thickness: 2,
              ),
              afterLineStyle: LineStyle(
                color: neonCyan,
                thickness: 2,
              ),
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: neonPink,
                iconStyle: IconStyle(
                  iconData: Icons.circle,
                  color: bgColor,
                ),
              ),
              startChild: Padding(
                padding: startPad,
                child: SizedBox(
                  width: 60, // Increased width to fit full year
                  child: Text(
                    data["year"]!,
                    style: GoogleFonts.orbitron(
                      color: neonPink,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              endChild: Padding(
                padding: endPad,
                child: Text(
                  data["event"]!,
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
