
class EventRound {
  final String title;
  final String date;
  final String time;
  final String? description;

  const EventRound({
    required this.title,
    required this.date,
    required this.time,
    this.description,
  });

  factory EventRound.fromJson(Map<String, dynamic> json) => EventRound(
        title: json['title'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
        'time': time,
        'description': description,
      };
}

class EventFaq {
  final String question;
  final String answer;

  const EventFaq({
    required this.question,
    required this.answer,
  });

  factory EventFaq.fromJson(Map<String, dynamic> json) => EventFaq(
        question: json['question'] ?? '',
        answer: json['answer'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class PrizeCategory {
  final String categoryName;
  final Map<String, String> prizes;

  const PrizeCategory({
    required this.categoryName,
    required this.prizes,
  });

  factory PrizeCategory.fromJson(Map<String, dynamic> json) => PrizeCategory(
        categoryName: json['categoryName'] ?? '',
        prizes: Map<String, String>.from(json['prizes'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'categoryName': categoryName,
        'prizes': prizes,
      };
}

class EventCoordinator {
  final String name;
  final String role;
  final String phone;
  final String? email;

  const EventCoordinator({
    required this.name,
    required this.role,
    required this.phone,
    this.email,
  });

  factory EventCoordinator.fromJson(Map<String, dynamic> json) => EventCoordinator(
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'phone': phone,
        'email': email,
      };
}

class EventDetail {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageAsset;
  final String? category;
  final String? prizePool;
  final String? teamSize;
  final String? date;
  final String? time;
  final String? venue;
  final String? mapLocationUrl;
  final List<String> rules;
  final List<String> whoCanParticipate;
  final List<EventRound> rounds;
  final List<EventFaq> faqs;
  final List<PrizeCategory> prizeCategories;
  final Map<String, String>? prizeBreakdown;
  final List<EventCoordinator> coordinators;
  final String? redirectUrl;
  final String? rulebookUrl;
  final String? problemStatementUrl;
  final String? whatsappUrl;
  final List<String> galleryImages;

  const EventDetail({
    this.id = '',
    required this.title,
    this.subtitle,
    this.description,
    this.imageAsset,
    this.category,
    this.prizePool,
    this.teamSize,
    this.date,
    this.time,
    this.venue,
    this.mapLocationUrl,
    this.rules = const [],
    this.whoCanParticipate = const [],
    this.rounds = const [],
    this.faqs = const [],
    this.prizeCategories = const [],
    this.prizeBreakdown,
    this.coordinators = const [],
    this.redirectUrl,
    this.rulebookUrl,
    this.problemStatementUrl,
    this.whatsappUrl,
    this.galleryImages = const [],
  });

  factory EventDetail.fromJson(Map<String, dynamic> json) => EventDetail(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'],
        description: json['description'],
        imageAsset: json['imageAsset'],
        category: json['category'],
        prizePool: json['prizePool'],
        teamSize: json['teamSize'],
        date: json['date'],
        time: json['time'],
        venue: json['venue'],
        mapLocationUrl: json['mapLocationUrl'],
        rules: List<String>.from(json['rules'] ?? []),
        whoCanParticipate: List<String>.from(json['whoCanParticipate'] ?? []),
        rounds: (json['rounds'] as List? ?? [])
            .map((r) => EventRound.fromJson(r))
            .toList(),
        faqs: (json['faqs'] as List? ?? [])
            .map((f) => EventFaq.fromJson(f))
            .toList(),
        prizeCategories: (json['prizeCategories'] as List? ?? [])
            .map((p) => PrizeCategory.fromJson(p))
            .toList(),
        prizeBreakdown: json['prizeBreakdown'] != null
            ? Map<String, String>.from(json['prizeBreakdown'])
            : null,
        coordinators: (json['coordinators'] as List? ?? [])
            .map((c) => EventCoordinator.fromJson(c))
            .toList(),
        redirectUrl: json['redirectUrl'],
        rulebookUrl: json['rulebookUrl'],
        problemStatementUrl: json['problemStatementUrl'],
        whatsappUrl: json['whatsappUrl'],
        galleryImages: List<String>.from(json['galleryImages'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'imageAsset': imageAsset,
        'category': category,
        'prizePool': prizePool,
        'teamSize': teamSize,
        'date': date,
        'time': time,
        'venue': venue,
        'mapLocationUrl': mapLocationUrl,
        'rules': rules,
        'whoCanParticipate': whoCanParticipate,
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'faqs': faqs.map((f) => f.toJson()).toList(),
        'prizeCategories': prizeCategories.map((p) => p.toJson()).toList(),
        'prizeBreakdown': prizeBreakdown,
        'coordinators': coordinators.map((c) => c.toJson()).toList(),
        'redirectUrl': redirectUrl,
        'rulebookUrl': rulebookUrl,
        'problemStatementUrl': problemStatementUrl,
        'whatsappUrl': whatsappUrl,
        'galleryImages': galleryImages,
      };

  String get effectiveId {
    if (id.trim().isNotEmpty) return id.trim();
    final clean = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'event_$clean';
  }

  DateTime? get parsedStartDateTime {
    if (date == null || date!.trim().isEmpty) return null;
    final dateStr = date!.trim().toLowerCase();
    final timeStr = time?.trim().toLowerCase() ?? '10:00 am';

    int year = 2026;
    int month = 8;
    int day = 28;

    if (dateStr.contains('today')) {
      final now = DateTime.now();
      year = now.year;
      month = now.month;
      day = now.day;
    } else {
      final dayMatch = RegExp(r'\b(\d{1,2})\b').firstMatch(dateStr);
      if (dayMatch != null) {
        day = int.tryParse(dayMatch.group(1)!) ?? 28;
      }

      if (dateStr.contains('aug')) {
        month = 8;
      } else if (dateStr.contains('sep')) {
        month = 9;
      } else if (dateStr.contains('oct')) {
        month = 10;
      } else if (dateStr.contains('jul')) {
        month = 7;
      } else if (dateStr.contains('nov')) {
        month = 11;
      } else if (dateStr.contains('dec')) {
        month = 12;
      }

      final yearMatch = RegExp(r'\b(202\d)\b').firstMatch(dateStr);
      if (yearMatch != null) {
        year = int.tryParse(yearMatch.group(1)!) ?? 2026;
      }
    }

    int hour = 10;
    int minute = 0;
    final timeMatch =
        RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?', caseSensitive: false)
            .firstMatch(timeStr);
    if (timeMatch != null) {
      int parsedHour = int.tryParse(timeMatch.group(1)!) ?? 10;
      minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      final meridian = timeMatch.group(3)?.toLowerCase();
      if (meridian == 'pm' && parsedHour < 12) {
        parsedHour += 12;
      } else if (meridian == 'am' && parsedHour == 12) {
        parsedHour = 0;
      }
      hour = parsedHour;
    }

    return DateTime(year, month, day, hour, minute);
  }
}

class SubCategory {
  final String title;
  final String imageAsset;
  final List<EventDetail> events;

  const SubCategory({
    required this.title,
    required this.imageAsset,
    required this.events,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        title: json['title'] ?? '',
        imageAsset: json['imageAsset'] ?? '',
        events: (json['events'] as List? ?? [])
            .map((e) => EventDetail.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageAsset': imageAsset,
        'events': events.map((e) => e.toJson()).toList(),
      };
}

class MainCategory {
  final String title;
  final List<SubCategory> subCategories;

  const MainCategory({
    required this.title,
    required this.subCategories,
  });

  factory MainCategory.fromJson(Map<String, dynamic> json) => MainCategory(
        title: json['title'] ?? '',
        subCategories: (json['subCategories'] as List? ?? [])
            .map((s) => SubCategory.fromJson(s))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subCategories': subCategories.map((s) => s.toJson()).toList(),
      };
}

EventDetail? findEventById(String id) {
  final cleanId = id.trim().toLowerCase();
  for (final mainCat in eventData) {
    for (final subCat in mainCat.subCategories) {
      for (final event in subCat.events) {
        if (event.effectiveId == cleanId || event.id == id) {
          return event;
        }
      }
    }
  }
  return null;
}

EventDetail? findEventByTitle(String title) {
  final cleanQuery = title.trim().toLowerCase();
  for (final mainCat in eventData) {
    for (final subCat in mainCat.subCategories) {
      for (final event in subCat.events) {
        if (event.title.trim().toLowerCase() == cleanQuery ||
            cleanQuery.contains(event.title.trim().toLowerCase()) ||
            event.title.trim().toLowerCase().contains(cleanQuery)) {
          return event;
        }
      }
    }
  }
  return null;
}

final List<MainCategory> eventData = [
  MainCategory(
    title: 'Competitions',
    subCategories: [
      SubCategory(
        title: 'Robotics',
        imageAsset: 'assets/robotics.jpeg',
        events: const [
          EventDetail(
            title: 'Robowars',
            subtitle: 'The Ultimate Combat Robotics Arena',
            category: 'Robotics',
            imageAsset: 'assets/robo.png',
            prizePool: '₹ 1,50,000',
            teamSize: '2 - 6 Members',
            date: 'Sep 4 - Sep 6, 2026',
            time: '10:00 AM - 6:00 PM',
            venue: 'L1 - Lecture Hall, Near Academic Block',
            mapLocationUrl: 'https://maps.google.com/?q=IIT+Guwahati+Lecture+Hall',
            whatsappUrl: 'https://chat.whatsapp.com/invite/techniche2026',
            description:
                'Robowars, a major event at Techniche, showcases top talents in robotics through intense competition. Participants design and develop wireless, manually controlled robots to engage in dual combat within a secure enclosed arena with destructive weapons, spinners, lifters, and battle mechanics.',
            rounds: [
              EventRound(
                title: 'Round 1: Online test (Unstop)',
                date: '25th Aug, 2026',
                time: '12:00',
                description: 'Screening round testing mechanical aptitude, circuit design, and safety guidelines.',
              ),
              EventRound(
                title: 'Round 2: Strategy Ideation & Flowchart',
                date: '27th Aug, 2026',
                time: '12:00',
                description: 'Submission and jury review of CAD models, weapon specs, and fail-safe mechanisms.',
              ),
              EventRound(
                title: 'Round 3: Main Arena Combat Showdown',
                date: '4th Sep, 2026',
                time: '10:00',
                description: 'Live bot vs bot duals in the high-voltage arena at IIT Guwahati.',
              ),
            ],
            whoCanParticipate: [
              'Any student with a valid college ID.',
              'Teams may have up to 3 members.',
              'Members can be from different institutes.',
            ],
            rules: [
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco.',
              'laboris nisi ut aliquip ex ea commodo consequat.',
            ],
            faqs: [
              EventFaq(
                question: 'Accordion row collapsed default',
                answer: 'Detailed response with competition specifications, submission deadlines, and arena guidelines.',
              ),
              EventFaq(
                question: 'Accordion row collapsed default',
                answer: 'Standard safety gear, batteries, and remote controller frequencies approved for use.',
              ),
              EventFaq(
                question: 'Accordion row collapsed default',
                answer: 'Accommodation, transport reimbursement, and on-campus food details for finalists.',
              ),
            ],
            coordinators: [
              EventCoordinator(
                name: 'Atharva Pratap Singh',
                role: 'Head Organizer',
                phone: '+91 1234567890',
                email: 's.atharva@iitg.ac.in',
              ),
            ],
            prizeCategories: [
              PrizeCategory(
                categoryName: 'Category 1: 30kg',
                prizes: {
                  'Winner': 'Rs. XXXXX',
                  '1st Runner up': 'Rs. XXXXX',
                  '2nd Runner up': 'Rs. XXXXX',
                },
              ),
              PrizeCategory(
                categoryName: 'Category 2: 15kg',
                prizes: {
                  'Winner': 'Rs. XXXXX',
                  '1st Runner up': 'Rs. XXXXX',
                  '2nd Runner up': 'Rs. XXXXX',
                },
              ),
            ],
            prizeBreakdown: {
              '1st Place (Champion)': '₹ 80,000 + Trophy & Certificate',
              '2nd Place (Runner Up)': '₹ 45,000 + Certificate of Excellence',
              '3rd Place (2nd Runner Up)': '₹ 25,000 + Certificate of Excellence',
            },
            redirectUrl: 'https://unstop.com/competitions/robowars-techniche-2026-iit-guwahati',
            rulebookUrl: 'https://techniche.org.in/rulebooks/robowars.pdf',
          ),
          EventDetail(
            title: 'Aquawars',
            subtitle: 'Naval Robotics & Underwater Warfare',
            category: 'Robotics',
            imageAsset: 'assets/robotics.jpeg',
            prizePool: '₹ 60,000',
            teamSize: '2 - 4 Members',
            date: 'Sep 5, 2026',
            time: '11:00 AM - 4:00 PM',
            venue: 'Olympic Swimming Pool Complex, IIT Guwahati',
            description:
                'Aquawars challenges participants to design autonomous or remote-controlled amphibious and aquatic robots capable of navigating turbulent water obstacles, retrieving submerged payloads, and completing high-precision naval maneuvers.',
            rules: [
              'Teams must construct a remote-controlled or autonomous boat/submarine robot.',
              'Robot must be completely waterproofed for electrical components and battery packs.',
              'Maximum dimensions: 50cm x 50cm x 50cm.',
              'Tasks include slalom navigation, ball retrieval, and docking in designated zones.',
              'Usage of hazardous chemicals, fuels, or corrosive substances is strictly prohibited.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 32,000 + Trophy',
              '2nd Place': '₹ 18,000 + Certificate',
              '3rd Place': '₹ 10,000 + Certificate',
            },
            coordinators: [
              EventCoordinator(
                name: 'Priya Singh',
                role: 'Event Lead',
                phone: '+91 98765 11223',
                email: 'priya@techniche.org.in',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/aquawars-techniche-2026',
          ),
          EventDetail(
            title: 'UVDC',
            subtitle: 'Unmanned Vehicle Design Competition',
            category: 'Robotics',
            imageAsset: 'assets/robotics.jpeg',
            prizePool: '₹ 75,000',
            teamSize: '2 - 5 Members',
            date: 'Sep 5, 2026',
            time: '9:00 AM - 2:00 PM',
            venue: 'Gymkhana Ground, IIT Guwahati',
            description:
                'UVDC tests your engineering prowess in designing unmanned aerial or ground vehicles capable of waypoint navigation, payload delivery, and dynamic obstacle avoidance in unpredictable terrain.',
            rules: [
              'UAVs / UGVs must follow specified dimensions and weight constraints.',
              'Must complete waypoint navigation autonomously or semi-autonomously.',
              'Payload must be safely dropped or retrieved in the drop circle.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 40,000',
              '2nd Place': '₹ 22,000',
              '3rd Place': '₹ 13,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Vikas Mehra',
                role: 'Event Lead',
                phone: '+91 97112 33445',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/uvdc-techniche-2026',
          ),
          EventDetail(
            title: 'Track Titans',
            subtitle: 'High-Speed Autonomous Line Following & Obstacle Racing',
            category: 'Robotics',
            imageAsset: 'assets/robotics.jpeg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 4 Members',
            date: 'Sep 6, 2026',
            time: '10:00 AM - 3:00 PM',
            venue: 'Auditorium Foyer, IIT Guwahati',
            description:
                'Build lightning-fast autonomous rovers that can detect line paths, dynamic loops, sharp turns, bridges, and cross-junctions with sub-millisecond PID tuning.',
            rules: [
              'Robots must be 100% autonomous with onboard sensor processing.',
              'No external communication or RF transmission during the run.',
              'Fastest completion time without deviating off-track wins.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 28,000',
              '2nd Place': '₹ 14,000',
              '3rd Place': '₹ 8,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Karan Patel',
                role: 'Coordinator',
                phone: '+91 98223 34455',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/track-titans-techniche-2026',
          ),
          EventDetail(
            title: 'Micro Mouse',
            subtitle: 'Autonomous Maze Solving at Breakneck Speed',
            category: 'Robotics',
            imageAsset: 'assets/micro.png',
            prizePool: '₹ 40,000',
            teamSize: '1 - 3 Members',
            date: 'Sep 6, 2026',
            time: '2:00 PM - 5:00 PM',
            venue: 'Core 4 Lobby, IIT Guwahati',
            description:
                'Micro Mouse is the quintessential robotics challenge: an autonomous vehicular robot that maps, calculates optimal shortest path algorithms (FloodFill, Dijkstra, A*), and dashes to the maze center at blistering speeds.',
            rules: [
              'The bot must be entirely autonomous and fit within 16cm x 16cm footprint.',
              'Maze layout is revealed only at the start of the official rounds.',
              'Points are awarded for mapping accuracy and fastest sprint run.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 22,000',
              '2nd Place': '₹ 12,000',
              '3rd Place': '₹ 6,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Aniket Gupta',
                role: 'Event Lead',
                phone: '+91 96541 22334',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/micro-mouse-techniche-2026',
          ),
          EventDetail(
            title: 'Escalade',
            subtitle: 'All-Terrain Climbing & Traverse Robotics',
            category: 'Robotics',
            imageAsset: 'assets/escalade.png',
            prizePool: '₹ 80,000',
            teamSize: '2 - 4 Members',
            date: 'Sep 4, 2026',
            time: '1:00 PM - 6:00 PM',
            venue: 'Amphitheatre, IIT Guwahati',
            description:
                'Design a high-torque mechanical climber capable of ascending steep inclinations, climbing vertical cables, crossing suspended ladders, and carrying payloads across rugged synthetic terrain.',
            rules: [
              'Bots must traverse multi-stage incline tracks and vertical zip ropes.',
              'Time penalties apply for drops or manual interventions.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 45,000',
              '2nd Place': '₹ 23,000',
              '3rd Place': '₹ 12,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Devansh Roy',
                role: 'Lead Coordinator',
                phone: '+91 91234 99887',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/escalade-techniche-2026',
          ),
        ],
      ),
      SubCategory(
        title: 'Funniche',
        imageAsset: 'assets/funniche.png',
        events: const [
          EventDetail(
            title: 'BGMI',
            subtitle: 'Battlegrounds Mobile India Championship',
            category: 'Funniche',
            imageAsset: 'assets/funniche.png',
            prizePool: '₹ 35,000',
            teamSize: '4 Players (Squad)',
            date: 'Sep 4 - Sep 5, 2026',
            time: '4:00 PM Onwards',
            venue: 'SAC Gaming Arena / Online',
            description:
                'Squad up for the most intense battle royale esports tournament of Techniche. Drop into Erangel and Miramar, clutch gunfights, and claim the Chicken Dinner.',
            rules: [
              'Only mobile devices are allowed (No emulators, iPad, or tablet devices).',
              'Maps: Erangel, Miramar, Sanhok in TPP Squad mode.',
              'Scoring is based on standard official BGIS point matrix.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 20,000',
              '2nd Place': '₹ 10,000',
              '3rd Place': '₹ 5,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Arjun Das',
                role: 'Esports Head',
                phone: '+91 99887 76655',
              ),
            ],
            redirectUrl: 'https://unstop.com/esports/bgmi-techniche-2026',
          ),
          EventDetail(
            title: 'Valorant',
            subtitle: '5v5 Tactical FPS Showdown',
            category: 'Funniche',
            imageAsset: 'assets/funniche.png',
            prizePool: '₹ 45,000',
            teamSize: '5 Players (+1 Sub)',
            date: 'Sep 5 - Sep 6, 2026',
            time: '11:00 AM Onwards',
            venue: 'Computer Center LAN Arena, IITG',
            description:
                'Lock in your duelists, initiate executes, and outplay your opponents in the Premier Techniche Valorant LAN tournament. Standard competitive plant/defuse format.',
            rules: [
              'Tournament mode with standard map veto system.',
              'Matches are Best of 1 until Semi-Finals, Finals are Best of 3.',
              'Vanguard anti-cheat and tournament lobby rules apply.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 25,000',
              '2nd Place': '₹ 13,000',
              '3rd Place': '₹ 7,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Siddharth Joshi',
                role: 'Valorant Lead',
                phone: '+91 98765 00112',
              ),
            ],
            redirectUrl: 'https://unstop.com/esports/valorant-techniche-2026',
          ),
          EventDetail(
            title: 'Chess',
            subtitle: 'Rapid & Blitz Strategic Tournament',
            category: 'Funniche',
            imageAsset: 'assets/funniche.png',
            prizePool: '₹ 20,000',
            teamSize: 'Individual (1 Player)',
            date: 'Sep 5, 2026',
            time: '10:00 AM',
            venue: 'Conference Hall, Old SAC',
            description:
                'FIDE-rated swiss-style chess championship testing strategic acumen, tactical calculation, and endgame mastery.',
            rules: [
              'Time control: 10 mins + 5 seconds increment per move.',
              'FIDE rules and standard touch-move rules apply strictly.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 10,000',
              '2nd Place': '₹ 6,000',
              '3rd Place': '₹ 4,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Naman Jain',
                role: 'Chess Convener',
                phone: '+91 97766 55443',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/chess-techniche-2026',
          ),
          EventDetail(
            title: 'Smash Karts',
            subtitle: 'Fast-Paced 3D Arcade Kart Battle',
            category: 'Funniche',
            imageAsset: 'assets/funniche.png',
            prizePool: '₹ 15,000',
            teamSize: 'Individual (1 Player)',
            date: 'Sep 6, 2026',
            time: '3:00 PM',
            venue: 'SAC Lounge, IIT Guwahati',
            description:
                'Grab power-ups, fire rockets, and drift through chaotic multiplayer kart battles to climb the leaderboard.',
            rules: [
              'Free-For-All deathmatch rounds.',
              'Top scorers from each heat advance to the Grand Finale.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 8,000',
              '2nd Place': '₹ 4,500',
              '3rd Place': '₹ 2,500',
            },
            coordinators: [
              EventCoordinator(
                name: 'Tanmay Saxena',
                role: 'Coordinator',
                phone: '+91 95544 33221',
              ),
            ],
            redirectUrl: 'https://unstop.com/esports/smash-karts-techniche-2026',
          ),
        ],
      ),
      SubCategory(
        title: 'Avinya',
        imageAsset: 'assets/avinya.webp',
        events: const [],
      ),
      SubCategory(
        title: 'STPI',
        imageAsset: 'assets/stpi.jpg',
        events: const [
          EventDetail(
            title: 'IoT in Agriculture',
            subtitle: 'Smart Farming & AgriTech Innovations',
            category: 'STPI',
            imageAsset: 'assets/stpi.jpg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 4 Members',
            date: 'Sep 5, 2026',
            time: '10:00 AM - 4:00 PM',
            venue: 'Core 1 Lecture Hall, IITG',
            description:
                'Develop IoT-enabled agricultural solutions such as smart soil moisture monitoring, automated irrigation, crop health detection, and supply chain telemetry.',
            rules: [
              'Prototypes must include functional hardware sensors and cloud/mobile dashboards.',
              'Judging based on novelty, feasibility, cost efficiency, and societal impact.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 28,000',
              '2nd Place': '₹ 14,000',
              '3rd Place': '₹ 8,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Sneha Agarwal',
                role: 'Domain Lead',
                phone: '+91 98111 22334',
              ),
            ],
            redirectUrl: 'https://unstop.com/hackathons/stpi-iot-techniche-2026',
          ),
          EventDetail(
            title: 'Gaming & Entertainment',
            subtitle: 'Next-Gen Game Development Hackathon',
            category: 'STPI',
            imageAsset: 'assets/stpi.jpg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 4 Members',
            date: 'Sep 4 - Sep 5, 2026',
            time: '24 Hours Hackathon',
            venue: 'Computer Center, IITG',
            description:
                'Create captivating 2D/3D games, immersive narrative experiences, or interactive entertainment apps using Unity, Unreal, Godot, or WebGL.',
            rules: [
              'Games must be developed during the fest based on the announced theme.',
              'Asset store usage must be clearly disclosed and justified.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 28,000',
              '2nd Place': '₹ 14,000',
              '3rd Place': '₹ 8,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Manish Kaul',
                role: 'GameDev Lead',
                phone: '+91 97222 33445',
              ),
            ],
            redirectUrl: 'https://unstop.com/hackathons/stpi-gamedev-techniche-2026',
          ),
          EventDetail(
            title: 'AR/VR & Emerging Tech',
            subtitle: 'Spatial Computing & Virtual Reality Solutions',
            category: 'STPI',
            imageAsset: 'assets/stpi.jpg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 4 Members',
            date: 'Sep 5, 2026',
            time: '11:00 AM',
            venue: 'Design Department, IITG',
            description:
                'Build interactive augmented reality or virtual reality applications for education, healthcare, industrial simulation, or architectural visualization.',
            rules: [
              'Applications can target Meta Quest, VisionOS, ARCore, or WebXR.',
              'Demo must be executable live in front of the jury panel.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 28,000',
              '2nd Place': '₹ 14,000',
              '3rd Place': '₹ 8,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Kavita Rao',
                role: 'Coordinator',
                phone: '+91 94333 22110',
              ),
            ],
            redirectUrl: 'https://unstop.com/hackathons/stpi-arvr-techniche-2026',
          ),
          EventDetail(
            title: 'Data Analytics & AI',
            subtitle: 'Predictive Modeling & Generative AI Solutions',
            category: 'STPI',
            imageAsset: 'assets/stpi.jpg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 3 Members',
            date: 'Sep 4 - Sep 6, 2026',
            time: 'Full Fest Challenge',
            venue: 'Online / Lab 3',
            description:
                'Tackle complex real-world datasets with machine learning, deep learning, LLMs, and computer vision models to solve predictive problems.',
            rules: [
              'Notebooks and reproducibility documentation must be submitted on GitHub.',
              'Standard evaluation metric (F1-score / RMSE) will determine top leaderboard.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 28,000',
              '2nd Place': '₹ 14,000',
              '3rd Place': '₹ 8,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Deepak Nair',
                role: 'AI Track Head',
                phone: '+91 98888 11223',
              ),
            ],
            redirectUrl: 'https://unstop.com/hackathons/stpi-ai-techniche-2026',
          ),
          EventDetail(
            title: 'Graphic Design & Animation',
            subtitle: 'Visual Identity, Motion Design & 3D Art',
            category: 'STPI',
            imageAsset: 'assets/stpi.jpg',
            prizePool: '₹ 40,000',
            teamSize: 'Individual (1 Participant)',
            date: 'Sep 5, 2026',
            time: '2:00 PM - 6:00 PM',
            venue: 'Design Dept Media Lab, IITG',
            description:
                'Craft breathtaking motion graphics, visual brand identity, UI/UX concept designs, and 3D renders addressing a prompt released on spot.',
            rules: [
              'All design assets and source files (.psd, .ai, .blend) must be submitted.',
              'Plagiarism from uncredited templates results in immediate disqualification.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 22,000',
              '2nd Place': '₹ 12,000',
              '3rd Place': '₹ 6,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Ritika Sen',
                role: 'Design Convener',
                phone: '+91 97711 44556',
              ),
            ],
            redirectUrl: 'https://unstop.com/competitions/stpi-design-techniche-2026',
          ),
          EventDetail(
            title: 'GIS Applications',
            subtitle: 'Spatial Mapping & Remote Sensing Challenge',
            category: 'STPI',
            imageAsset: 'assets/stpi.jpg',
            prizePool: '₹ 40,000',
            teamSize: '1 - 3 Members',
            date: 'Sep 6, 2026',
            time: '10:00 AM',
            venue: 'Civil Engineering Seminar Hall',
            description:
                'Harness satellite imagery, geospatial databases (QGIS, ArcGIS, Mapbox), and spatial analysis to solve urban planning and disaster relief challenges.',
            rules: [
              'Submissions must include interactive geospatial maps and methodology reports.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 22,000',
              '2nd Place': '₹ 12,000',
              '3rd Place': '₹ 6,000',
            },
            coordinators: [
              EventCoordinator(
                name: 'Prateek Jain',
                role: 'GIS Coordinator',
                phone: '+91 93344 55667',
              ),
            ],
            redirectUrl: 'https://unstop.com/hackathons/stpi-gis-techniche-2026',
          ),
        ],
      ),
      SubCategory(
        title: 'CatalysisT',
        imageAsset: 'assets/cata.jpg',
        events: const [],
      ),
      SubCategory(
        title: 'Technothlon',
        imageAsset: 'assets/techno.png',
        events: const [
          EventDetail(
            title: 'Junior Squad',
            subtitle: 'Logic & Aptitude Olympiad for Classes 9 & 10',
            category: 'Technothlon',
            imageAsset: 'assets/techno.png',
            prizePool: '₹ 1,00,000 + Medals',
            teamSize: '2 Students',
            date: 'Sep 5, 2026',
            time: '9:00 AM - 1:00 PM',
            venue: 'Lecture Hall Complex, IIT Guwahati',
            description:
                'Technothlon Junior Squad is the ultimate test of logical reasoning, mental agility, and intuitive problem-solving for school students from classes 9 and 10.',
            rules: [
              'Teams must consist of exactly 2 students from the same or different schools.',
              'No syllabus or rote learning required; questions test pure logic and creativity.'
            ],
            prizeBreakdown: {
              '1st Place (AIR 1)': '₹ 50,000 + Gold Medals',
              '2nd Place (AIR 2)': '₹ 30,000 + Silver Medals',
              '3rd Place (AIR 3)': '₹ 20,000 + Bronze Medals',
            },
            coordinators: [
              EventCoordinator(
                name: 'Technothlon Team',
                role: 'Overall Coordinators',
                phone: '+91 98765 43210',
                email: 'technothlon@techniche.org.in',
              ),
            ],
            redirectUrl: 'https://technothlon.techniche.org.in',
          ),
          EventDetail(
            title: 'Hauts Squad',
            subtitle: 'Advanced Logic & Critical Thinking for Classes 11 & 12',
            category: 'Technothlon',
            imageAsset: 'assets/techno.png',
            prizePool: '₹ 1,00,000 + Medals',
            teamSize: '2 Students',
            date: 'Sep 5, 2026',
            time: '2:00 PM - 6:00 PM',
            venue: 'Lecture Hall Complex, IIT Guwahati',
            description:
                'Technothlon Hauts Squad challenges senior high-school minds with groundbreaking puzzles, algorithmic deduction, and cryptic mathematical reasoning.',
            rules: [
              'Teams must consist of exactly 2 students from classes 11 or 12.',
              'Top teams qualify for the Grand Finale held on IIT Guwahati campus.'
            ],
            prizeBreakdown: {
              '1st Place (AIR 1)': '₹ 50,000 + Gold Medals',
              '2nd Place (AIR 2)': '₹ 30,000 + Silver Medals',
              '3rd Place (AIR 3)': '₹ 20,000 + Bronze Medals',
            },
            coordinators: [
              EventCoordinator(
                name: 'Technothlon Team',
                role: 'Overall Coordinators',
                phone: '+91 98765 43210',
                email: 'technothlon@techniche.org.in',
              ),
            ],
            redirectUrl: 'https://technothlon.techniche.org.in',
          ),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Workshops',
    subCategories: [
      SubCategory(
        title: "Bioinformatics & Cancer Research Workshop",
        imageAsset: 'assets/workshops/world-technocon-bioinformatics-cancer-research.webp',
        events: const [
          EventDetail(
            title: "Bioinformatics & Cancer Research Workshop",
            subtitle: "Explore computational biology, genomic data analysis, and cutting-edge cancer research methodologies.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-bioinformatics-cancer-research.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Explore computational biology, genomic data analysis, and cutting-edge cancer research methodologies.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/bioinformatics-and-cancer-research-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "CRISPR in Computational Genomics Workshop",
        imageAsset: 'assets/workshops/world-technocon-crispr-in-computational-genomics.webp',
        events: const [
          EventDetail(
            title: "CRISPR in Computational Genomics Workshop",
            subtitle: "Hands-on insights into gene editing technologies, CRISPR toolkits, and computational gene sequencing.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-crispr-in-computational-genomics.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Hands-on insights into gene editing technologies, CRISPR toolkits, and computational gene sequencing.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/quantum-computing-basics-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Human Resource Mastery Workshop",
        imageAsset: 'assets/workshops/world-technocon-human-resource-mastery-from-fundamentals.webp',
        events: const [
          EventDetail(
            title: "Human Resource Mastery Workshop",
            subtitle: "Master modern HR strategies, talent acquisition, performance management, and organizational analytics.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-human-resource-mastery-from-fundamentals.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Master modern HR strategies, talent acquisition, performance management, and organizational analytics.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/human-resource-mastery-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Generative AI Masterclass (17+ AI Tools)",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-masterclass-master-17.webp',
        events: const [
          EventDetail(
            title: "Generative AI Masterclass (17+ AI Tools)",
            subtitle: "Learn to supercharge productivity by mastering 17+ state-of-the-art Generative AI platforms and workflows.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-generative-ai-masterclass-master-17.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Learn to supercharge productivity by mastering 17+ state-of-the-art Generative AI platforms and workflows.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/generative-ai-masterclass-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Data Science Mastery",
        imageAsset: 'assets/workshops/world-technocon-data-science-mastery-3.webp',
        events: const [
          EventDetail(
            title: "Data Science Mastery",
            subtitle: "Deep dive into data manipulation, statistical modeling, machine learning pipelines, and Python analytics.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-data-science-mastery-3.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Deep dive into data manipulation, statistical modeling, machine learning pipelines, and Python analytics.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/data-science-mastery-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "AI in Film and Reels Making Workshop",
        imageAsset: 'assets/workshops/world-technocon-ai-in-film-and-reels-making-copy-mrx4ey73.webp',
        events: const [
          EventDetail(
            title: "AI in Film and Reels Making Workshop",
            subtitle: "Harness AI video generators, voice synthesizers, and editing algorithms to create viral short films and reels.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-ai-in-film-and-reels-making-copy-mrx4ey73.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Harness AI video generators, voice synthesizers, and editing algorithms to create viral short films and reels.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ai-in-film-and-reels-making-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Diabetology & Metabolic Disorders",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-chatgpt-mastery-2.webp',
        events: const [
          EventDetail(
            title: "Diabetology & Metabolic Disorders",
            subtitle: "Clinical and technological perspectives on metabolic health, continuous glucose monitoring, and diabetes management.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-generative-ai-chatgpt-mastery-2.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Clinical and technological perspectives on metabolic health, continuous glucose monitoring, and diabetes management.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/diabetology-and-metabolic-disorders-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Claude For Non-Technical Professionals",
        imageAsset: 'assets/workshops/world-technocon-claude-for-non-technical-professionals.webp',
        events: const [
          EventDetail(
            title: "Claude For Non-Technical Professionals",
            subtitle: "Empower non-coders to automate writing, data summarization, project management, and reasoning with Claude AI.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-claude-for-non-technical-professionals.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Empower non-coders to automate writing, data summarization, project management, and reasoning with Claude AI.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/claude-for-non-technical-professionals-workshop-at-visvesvaraya-national-institute-of-technology",
          ),
        ],
      ),
      SubCategory(
        title: "Agentic AI Masterclass",
        imageAsset: 'assets/workshops/world-technocon-agentic-ai-masterclass-3-copy-mrx4eu55.webp',
        events: const [
          EventDetail(
            title: "Agentic AI Masterclass",
            subtitle: "Build autonomous AI agents, multi-agent frameworks, task loops, and tool-augmented AI models.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-agentic-ai-masterclass-3-copy-mrx4eu55.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Build autonomous AI agents, multi-agent frameworks, task loops, and tool-augmented AI models.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/agentic-ai-masterclass-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Innovation & Startup Ideas",
        imageAsset: 'assets/workshops/world-technocon-innovation-startup-ideas-2.webp',
        events: const [
          EventDetail(
            title: "Innovation & Startup Ideas",
            subtitle: "Transform raw ideas into scalable startups, craft pitch decks, validate product-market fit, and seek venture capital.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-innovation-startup-ideas-2.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Transform raw ideas into scalable startups, craft pitch decks, validate product-market fit, and seek venture capital.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/innovation-startup-ideas-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Digital Marketing with Instagram Meta Ads",
        imageAsset: 'assets/workshops/world-technocon-digital-marketing-with-google-ads-and-seo.webp',
        events: const [
          EventDetail(
            title: "Digital Marketing with Instagram Meta Ads",
            subtitle: "Master audience targeting, creative ad design, performance analytics, and ROI optimization on Instagram & Meta.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-digital-marketing-with-google-ads-and-seo.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "29-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Master audience targeting, creative ad design, performance analytics, and ROI optimization on Instagram & Meta.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/digital-marketing-google-ads-seo-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "AI in Drug Discovery Workshop",
        imageAsset: 'assets/workshops/world-technocon-ai-in-drug-discovery.webp',
        events: const [
          EventDetail(
            title: "AI in Drug Discovery Workshop",
            subtitle: "Discover how machine learning, molecular docking, and AI accelerate drug design and clinical trials.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-ai-in-drug-discovery.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Discover how machine learning, molecular docking, and AI accelerate drug design and clinical trials.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ai-for-healthcare-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Digital Marketing With Google Ads & SEO",
        imageAsset: 'assets/workshops/world-technocon-google-ads-seo-mastery-2.webp',
        events: const [
          EventDetail(
            title: "Digital Marketing With Google Ads & SEO",
            subtitle: "Rank #1 on search engines with technical SEO, keyword research, and high-converting Google Search & Display campaigns.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-google-ads-seo-mastery-2.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Rank #1 on search engines with technical SEO, keyword research, and high-converting Google Search & Display campaigns.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/digital-marketing-mastery-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "UX Design with AI",
        imageAsset: 'assets/workshops/world-technocon-ux-design-with-ai-3.webp',
        events: const [
          EventDetail(
            title: "UX Design with AI",
            subtitle: "Integrate generative design tools, wireframing AI, and user research agents into high-converting UX workflows.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-ux-design-with-ai-3.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Integrate generative design tools, wireframing AI, and user research agents into high-converting UX workflows.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ux-design-with-ai-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Entrepreneurship Essentials",
        imageAsset: 'assets/workshops/world-technocon-innovation-startup-ideas-2.webp',
        events: const [
          EventDetail(
            title: "Entrepreneurship Essentials",
            subtitle: "Essential business foundations: business models, legal structuring, financial planning, and operational scaling.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-innovation-startup-ideas-2.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Essential business foundations: business models, legal structuring, financial planning, and operational scaling.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/entrepreneurship-essentials-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Ethical Hacking & Cyber Security Workshop",
        imageAsset: 'assets/workshops/world-technocon-agentic-ai-masterclass-3-copy-mrx4eu55.webp',
        events: const [
          EventDetail(
            title: "Ethical Hacking & Cyber Security Workshop",
            subtitle: "Practical penetration testing, network vulnerability assessment, cryptography, and cyber defense tactics.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-agentic-ai-masterclass-3-copy-mrx4eu55.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Practical penetration testing, network vulnerability assessment, cryptography, and cyber defense tactics.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ethical-hacking-cyber-security-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Fashion Design & Entrepreneurship",
        imageAsset: 'assets/workshops/world-technocon-ux-design-with-ai-3.webp',
        events: const [
          EventDetail(
            title: "Fashion Design & Entrepreneurship",
            subtitle: "Combine fashion aesthetics, sustainable textile technology, brand identity, and e-commerce scaling.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-ux-design-with-ai-3.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Combine fashion aesthetics, sustainable textile technology, brand identity, and e-commerce scaling.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/fashion-design-entrepreneurship-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "AI & ML Fundamentals Workshop",
        imageAsset: 'assets/workshops/world-technocon-data-science-mastery-3.webp',
        events: const [
          EventDetail(
            title: "AI & ML Fundamentals Workshop",
            subtitle: "Core algorithms: regression, classification, neural networks, supervised/unsupervised learning fundamentals.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-data-science-mastery-3.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Core algorithms: regression, classification, neural networks, supervised/unsupervised learning fundamentals.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/aiml-fundamentals-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Interior Design Basics & Entrepreneurship",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-masterclass-master-17.webp',
        events: const [
          EventDetail(
            title: "Interior Design Basics & Entrepreneurship",
            subtitle: "3D interior modeling, space planning, materials selection, and launching a freelance interior design enterprise.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-generative-ai-masterclass-master-17.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "3D interior modeling, space planning, materials selection, and launching a freelance interior design enterprise.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/interior-design-entrepreneurship-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "Drone Building Workshop",
        imageAsset: 'assets/workshops/world-technocon-bioinformatics-cancer-research.webp',
        events: const [
          EventDetail(
            title: "Drone Building Workshop",
            subtitle: "Hands-on UAV drone assembly, flight controller programming, telemetry tuning, and aerial dynamics.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-bioinformatics-cancer-research.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Hands-on UAV drone assembly, flight controller programming, telemetry tuning, and aerial dynamics.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/drone-building-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "No-Code App Development using AI / Vibe Coding",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-chatgpt-mastery-2.webp',
        events: const [
          EventDetail(
            title: "No-Code App Development using AI / Vibe Coding",
            subtitle: "Build full-fledged web and mobile apps using AI prompt engineering, low-code tools, and modern vibe coding.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-generative-ai-chatgpt-mastery-2.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Build full-fledged web and mobile apps using AI prompt engineering, low-code tools, and modern vibe coding.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/no-code-app-development-ai-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
      SubCategory(
        title: "AI for Healthcare Professionals Workshop",
        imageAsset: 'assets/workshops/world-technocon-ai-in-drug-discovery.webp',
        events: const [
          EventDetail(
            title: "AI for Healthcare Professionals Workshop",
            subtitle: "Applications of medical AI in diagnostics, patient management systems, and clinical workflow automation.",
            category: "Workshops",
            imageAsset: 'assets/workshops/world-technocon-ai-in-drug-discovery.webp',
            prizePool: "Certified Workshop",
            teamSize: "Individual",
            date: "30-08-2026",
            time: "10:30 AM - 5:30 PM",
            venue: "IIT Guwahati",
            description: "Applications of medical AI in diagnostics, patient management systems, and clinical workflow automation.",
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ai-for-hr-professionals-workshop-at-iit-guwahati-august-2026",
          ),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Exhibitions',
    subCategories: [
      SubCategory(
        title: 'Tech-Expo',
        imageAsset: 'assets/techexpo.jpg',
        events: const [
          EventDetail(
            title: 'Tech-Expo (Juniors)',
            subtitle: 'School Innovations & Science Showcase',
            category: 'Exhibitions',
            imageAsset: 'assets/techexpo.jpg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 4 Students',
            venue: 'Exhibition Hall A, IIT Guwahati',
            description:
                'An esteemed platform for young school innovators to showcase working scientific models, green technology prototypes, and engineering inventions.',
          ),
          EventDetail(
            title: 'Tech-Expo (Seniors)',
            subtitle: 'National Research & College Innovation Showcase',
            category: 'Exhibitions',
            imageAsset: 'assets/techexpo.jpg',
            prizePool: '₹ 1,50,000',
            teamSize: '1 - 5 Members',
            venue: 'Exhibition Hall B, IIT Guwahati',
            description:
                'Showcase cutting-edge academic research projects, hardware patents, and deep-tech prototypes to renowned scientists, investors, and industrial leaders.',
          ),
        ],
      ),
      SubCategory(
        title: 'Army Expo',
        imageAsset: 'assets/army-expo.jpg',
        events: const [
          EventDetail(
            title: 'Indian Army Weapons Showcase',
            subtitle: 'Defense Technology & Weaponry Exhibition',
            category: 'Exhibitions',
            imageAsset: 'assets/army-expo.jpg',
            venue: 'Main Helipad Grounds, IIT Guwahati',
            description:
                'Experience state-of-the-art defense technology, artillery, tactical communication gear, and specialized military vehicles presented directly by the Indian Army.',
          ),
        ],
      ),
      SubCategory(
        title: 'Road Show',
        imageAsset: 'assets/road-show.webp',
        events: const [
          EventDetail(
            title: 'Supercars & Superbikes Showcase',
            subtitle: 'Fleet of Roadsters Roaring in Campus',
            category: 'Exhibitions',
            imageAsset: 'assets/road-show.webp',
            venue: 'Core 1 Boulevard, IIT Guwahati',
            description:
                'Witness an electrifying collection of exotic supercars, vintage classics, custom superbikes, and high-performance racing beasts revving through the campus.',
          ),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Lecture Series',
    subCategories: [
      SubCategory(
        title: 'Mr. Ashneer Grover',
        imageAsset: 'assets/ash.jpg',
        events: const [
          EventDetail(
            title: 'Keynote by Mr. Ashneer Grover',
            subtitle: 'Entrepreneurship, Fintech & Startup Ecosystem',
            category: 'Lecture Series',
            imageAsset: 'assets/ash.jpg',
            venue: 'Main Auditorium, IIT Guwahati',
            date: 'Sep 5, 2026',
            time: '5:00 PM',
            description:
                'Candid talk on building hyper-scale fintech companies, disrupting Indian retail payments, venture investments, and founder resilience.',
          ),
        ],
      ),
      SubCategory(
        title: 'Mr. PushkarRaj Salunke',
        imageAsset: 'assets/revamp.jpg',
        events: const [
          EventDetail(
            title: 'Keynote by Mr. PushkarRaj Salunke',
            subtitle: 'From Transformable EVs to Redefining Mobility',
            category: 'Lecture Series',
            imageAsset: 'assets/revamp.jpg',
            venue: 'Main Auditorium, IIT Guwahati',
            date: 'Sep 6, 2026',
            time: '11:00 AM',
            description:
                'Insights into EV engineering, modular chassis design, manufacturing innovation, and the future of clean urban mobility in India.',
          ),
        ],
      ),
      SubCategory(
        title: 'Mr. Dinesh Sharma',
        imageAsset: 'assets/asus.jpg',
        events: const [
          EventDetail(
            title: 'Keynote by Mr. Dinesh Sharma',
            subtitle: 'The Powerhouse Behind ASUS India’s Growth',
            category: 'Lecture Series',
            imageAsset: 'assets/asus.jpg',
            venue: 'Main Auditorium, IIT Guwahati',
            date: 'Sep 6, 2026',
            time: '3:00 PM',
            description:
                'Exploring consumer tech innovations, gaming ecosystem growth in India, and leadership strategies in competitive global tech brands.',
          ),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Nexus',
    subCategories: [
      SubCategory(
        title: 'Networking Events',
        imageAsset: 'assets/nexus.jpg',
        events: const [
          EventDetail(
            title: 'Icebreaking & Keynote',
            subtitle: 'Connect with Industry Titans & Fellow Founders',
            category: 'Nexus',
            imageAsset: 'assets/nexus.jpg',
            venue: 'Conference Center, IIT Guwahati',
            description:
                'Structured networking session bringing together startup founders, investors, researchers, and aspiring tech enthusiasts.',
          ),
          EventDetail(
            title: 'Live Project',
            subtitle: 'Real-world Corporate Problem Solving',
            category: 'Nexus',
            imageAsset: 'assets/nexus.jpg',
            venue: 'Seminar Hall 3, IIT Guwahati',
            description:
                'Collaborate in multidisciplinary teams to tackle real-world industry case studies with mentorship from corporate executives.',
          ),
          EventDetail(
            title: 'Mentorship',
            subtitle: '1-on-1 Guidance with Domain Experts',
            category: 'Nexus',
            imageAsset: 'assets/nexus.jpg',
            venue: 'SAC Executive Lounge, IIT Guwahati',
            description:
                'Get personalized feedback on your startup pitch, research thesis, career trajectory, and technical roadmaps from experienced mentors.',
          ),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Initiatives',
    subCategories: [
      SubCategory(
        title: 'Guwahati Half Marathon',
        imageAsset: 'assets/ghm.png',
        events: const [
          EventDetail(
            title: 'Blood Donation Drive',
            subtitle: 'Saving Lives Across Northeast India',
            category: 'Initiatives',
            imageAsset: 'assets/ghm.png',
            venue: 'IIT Guwahati Hospital Complex',
            description:
                'Join Techniche in our mission to support local healthcare centers and save lives through a mega blood donation campaign in collaboration with GMCH.',
          ),
          EventDetail(
            title: 'Food Distribution',
            subtitle: 'Zero Hunger Community Initiative',
            category: 'Initiatives',
            imageAsset: 'assets/ghm.png',
            venue: 'Guwahati City & Neighboring Villages',
            description:
                'Techniche’s social initiative aimed at redistributing meals and groceries to underprivileged communities and orphanages.',
          ),
        ],
      ),
    ],
  ),
];
