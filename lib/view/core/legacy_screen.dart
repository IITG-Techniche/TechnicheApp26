import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:techniche26/widgets/app_drawer.dart';

class LegacyPage extends StatefulWidget {
  static const String routeName = '/legacy';
  const LegacyPage({Key? key}) : super(key: key);

  @override
  State<LegacyPage> createState() => _LegacyPageState();
}

class _LegacyPageState extends State<LegacyPage> {
  final List<Map<String, dynamic>> timelineData = [
    {
      "year": "1999",
      "title": "Techniche",
      "event": "Journey of Techniche Begins",
      "icon": Icons.rocket_launch_rounded,
    },
    {
      "year": "2009",
      "title": "GHM",
      "event": "First edition of Guwahati Half Marathon (GHM) commenced.",
      "icon": Icons.directions_run_rounded,
    },
    {
      "year": "2010",
      "title": "Technothlon",
      "event":
          "Technothlon achieves global reach, emerging as India's premier logic exam for students.",
      "image": "assets/tchno_logo.png",
    },
    {
      "year": "2017",
      "title": "Pragati",
      "event":
          "Five neighbouring villages adopted under the pragati initiatives.",
      "icon": Icons.people_rounded,
    },
    {
      "year": "2023",
      "title": "Techniche",
      "event":
          "Techniche successfully completes 25 years, marking a silver milestone.",
      "icon": Icons.emoji_events_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'WHERE INNOVATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0XFF232930),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Univers',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Annual Techno-Management fest of IIT Guwahati, Largest in North-East India',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6D7985),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SF Pro',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 40),
                  const Text(
                    'LegacyTimeline',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Univers',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE1EBFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statCard('₹20 Lakhs', 'Prizes worth'),
              const SizedBox(width: 12),
              _statCard('1 lakh+', 'Lives impacted'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('50K+', 'Footfall'),
              const SizedBox(width: 12),
              _statCard('3x YoY', 'Growth'),
            ],
          ),
          const SizedBox(height: 12),
          _statCard('150K+', 'Meta Likes', width: 220),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, {double? width}) {
    return Expanded(
      flex: width != null ? 0 : 1,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF002B5B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Univers',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(timelineData.length, (index) {
        final data = timelineData[index];
        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.2,
          isFirst: index == 0,
          isLast: index == timelineData.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 90,
            height: 60,
            indicator: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF175BCC),
                shape: BoxShape.rectangle,
                border: Border.all(color: const Color(0xFF749DE0), width: 6),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3371E3).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  data['year'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Univers',
                  ),
                ),
              ),
            ),
          ),
          beforeLineStyle: const LineStyle(
            color: Color(0xFF3371E3),
            thickness: 3,
          ),
          afterLineStyle: const LineStyle(
            color: Color(0xFF3371E3),
            thickness: 3,
          ),
          endChild: Container(
            margin: const EdgeInsets.only(left: 16, bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE1EBFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (data.containsKey('image'))
                      Image.asset(data['image'],
                          width: 22, height: 22, fit: BoxFit.contain)
                    else
                      Icon(data['icon'],
                          color: const Color(0xFF002B5B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      data['title'],
                      style: const TextStyle(
                        color: Color(0xFF002B5B),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Univers',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['event'],
                  style: const TextStyle(
                    color: Color(0xFF6D7985),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
