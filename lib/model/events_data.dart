
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

EventDetail? findEventByTitle(String title) {
  final cleanQuery = title.trim().toLowerCase();
  for (final mainCat in eventData) {
    for (final subCat in mainCat.subCategories) {
      for (final event in subCat.events) {
        if (event.title.trim().toLowerCase() == cleanQuery) {
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
        title: 'Full Stack Web Development',
        imageAsset: 'assets/webdev.jpg',
        events: const [
          EventDetail(
            title: 'Full Stack Web Development',
            subtitle: 'Hands-on Bootcamp: Next.js, APIs & Cloud Deployment',
            category: 'Workshops',
            imageAsset: 'assets/webdev.jpg',
            prizePool: 'Certified Workshop',
            teamSize: 'Individual',
            date: 'Sep 4 - Sep 5, 2026',
            time: '10:00 AM - 5:00 PM',
            venue: 'Computer Center Lab 1, IITG',
            description:
                'Comprehensive hands-on workshop covering modern web architecture, frontend react frameworks, backend APIs, authentication, state management, and continuous cloud deployment.',
            rules: [
              'Participants should bring their own laptops with Node.js and VS Code pre-installed.',
              'Certificate of participation will be provided by IIT Guwahati Techniche.'
            ],
            redirectUrl:
                'https://unstop.com/workshops-webinars/full-stack-web-development-bootcamp-iit-guwahati-1541887',
          ),
        ],
      ),
      SubCategory(
        title: 'Arduino Project Development',
        imageAsset: 'assets/arduino.jpg',
        events: const [
          EventDetail(
            title: 'Arduino Project Development',
            subtitle: 'Microcontrollers, Embedded Systems & Hardware Interfacing',
            category: 'Workshops',
            imageAsset: 'assets/arduino.jpg',
            prizePool: 'Certified Workshop',
            teamSize: 'Individual',
            date: 'Sep 5, 2026',
            time: '9:30 AM - 4:30 PM',
            venue: 'Electronics Lab, IITG',
            description:
                'Learn microcontroller programming from scratch. Build real hardware projects with sensors, actuators, LCD displays, motor drivers, and serial communication.',
            redirectUrl:
                'https://unstop.com/workshops-webinars/arduino-project-development-workshop-iit-guwahati-1541858',
          ),
        ],
      ),
      SubCategory(
        title: 'Generative AI',
        imageAsset: 'assets/genai.jpg',
        events: const [
          EventDetail(
            title: 'Generative AI & Agentic Systems',
            subtitle: 'LLMs, Prompt Engineering, RAG & Autonomous Agents',
            category: 'Workshops',
            imageAsset: 'assets/genai.jpg',
            prizePool: 'Certified Workshop',
            teamSize: 'Individual',
            date: 'Sep 5 - Sep 6, 2026',
            time: '10:00 AM - 4:00 PM',
            venue: 'Auditorium Hall, IITG',
            description:
                'Deep dive into Large Language Models, fine-tuning, retrieval-augmented generation (RAG), and designing autonomous multi-agent AI systems with practical code examples.',
            redirectUrl:
                'https://unstop.com/workshops-webinars/generative-ai-agentic-ai-workshop-iit-guwahati-1541805',
          ),
        ],
      ),
      SubCategory(
        title: 'Cybersecurity',
        imageAsset: 'assets/cybersec.jpg',
        events: const [
          EventDetail(
            title: 'Cybersecurity & Ethical Hacking',
            subtitle: 'Penetration Testing, Network Defense & CTF Masterclass',
            category: 'Workshops',
            imageAsset: 'assets/cybersec.jpg',
            prizePool: 'Certified Workshop',
            teamSize: 'Individual',
            date: 'Sep 6, 2026',
            time: '10:00 AM - 5:00 PM',
            venue: 'Computer Center Lab 2, IITG',
            description:
                'Master the fundamentals of network security, web vulnerability scanning (OWASP Top 10), reverse engineering, cryptography, and real-time capture-the-flag exercises.',
            redirectUrl:
                'https://unstop.com/workshops-webinars/cybersecurity-and-ethical-hacking-workshop-iit-guwahati-1541776',
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
