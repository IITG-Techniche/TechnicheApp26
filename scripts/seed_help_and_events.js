const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

const rootKeyPath = path.join(__dirname, '..', 'techniche-269b1-firebase-adminsdk-fbsvc-0986ba1ba6.json');
const localKeyPath = path.join(__dirname, 'serviceAccountKey.json');

let serviceAccount;
if (fs.existsSync(rootKeyPath)) {
  serviceAccount = require(rootKeyPath);
} else if (fs.existsSync(localKeyPath)) {
  serviceAccount = require(localKeyPath);
} else {
  console.error('❌ Service account key JSON file not found.');
  process.exit(1);
}

try {
  initializeApp({ credential: cert(serviceAccount) });
  console.log('✅ Firebase Admin SDK initialized.');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK:', error.message);
  process.exit(1);
}

const db = getFirestore();

// ─── HELP CENTER DATA ────────────────────────────────────────────────────────
const helpCenterData = {
  hospital: [
    { name: 'Ambulance', number: '3612586666' },
    { name: 'Reception', number: '3612585555' }
  ],
  accommodation: [
    { name: 'Hospitality Head (Uday)', number: '9075438210' },
    { name: 'Hospitality Head (Raghav)', number: '9075438210' },
    { name: 'Hospitality Head (Vibha)', number: '9075438210' }
  ],
  transport: [
    { name: 'Buggy', number: '9213546678', timeSlot: '9:00-12:00' },
    { name: 'Erickshaw 1', number: '6001440472', timeSlot: '8:00-14:00' },
    { name: 'Erickshaw 2', number: '7896513761', timeSlot: '12:00-18:00' },
    { name: 'Erickshaw 3', number: '8486664856', timeSlot: '16:00-22:00' },
    { name: 'Erickshaw 4', number: '9123456780', timeSlot: '8:00-20:00' },
    { name: 'Erickshaw 5', number: '9876543210', timeSlot: '8:00-20:00' }
  ],
  faqs: [
    {
      question: 'How do i register for events?',
      answer: 'Visit the official website (techniche.org.in) or click on any event in the app to view details and register directly on Unstop.'
    },
    {
      question: 'Where can i find the event schedule?',
      answer: 'The complete event schedule with date-wise filtering, live venue navigation, and timing is available under the Schedule tab.'
    },
    {
      question: 'Is accomodation provided?',
      answer: 'Hostel accommodation is available on campus for registered participants on a first-come, first-served basis. Please contact the Hospitality Team heads listed above.'
    },
    {
      question: 'Who do i contact in case of emergency?',
      answer: 'For any medical emergencies, call the IIT Guwahati Hospital Ambulance (0361-2586666) or the Security Reception immediately.'
    },
    {
      question: 'How do I reach IIT Guwahati campus?',
      answer: 'IIT Guwahati is located around 20 km from Guwahati Railway Station and 22 km from Lokpriya Gopinath Bordoloi International Airport. Institute buses and pre-paid taxis/autos are readily available.'
    }
  ]
};

// ─── EVENTS DATA ─────────────────────────────────────────────────────────────
const eventCategories = [
  {
    title: 'Competitions',
    subCategories: [
      {
        title: 'Robowars',
        imageAsset: 'assets/events/robo-reduced.jpg',
        events: [
          {
            title: 'Robowars',
            subtitle: 'The Ultimate Combat Robotics Arena',
            category: 'Competitions',
            imageAsset: 'assets/events/robo-reduced.jpg',
            prizePool: '₹ 2,00,000',
            teamSize: '2 - 6 Members',
            date: '28-08-2026',
            time: '9:00 AM - 6:00 PM',
            venue: 'Gymkhana Grounds, IIT Guwahati',
            mapLocationUrl: 'https://maps.google.com/?q=IIT+Guwahati',
            description: 'Robowars, a major event at Techniche, showcases top talents in robotics through intense competition. Participants design and develop wireless, manually controlled robots to engage in dual combat within a specified arena. The event highlights innovative strategies, mechanical strength, and strategic maneuvering, creating a thrilling spectacle.',
            rounds: [],
            whoCanParticipate: [
              'Any student with a valid college ID.',
              'Teams of 2 to 6 members.',
              'Members can be from different institutes.'
            ],
            rules: [
              'Wireless, manually controlled combat robots.',
              'Robots compete in specified 30kg and 15kg weight categories.',
              'Strategic maneuvering and destructive battle mechanics permitted within arena bounds.'
            ],
            coordinators: [
              {
                name: 'Vomeshwar',
                role: 'Coordinator',
                phone: '+91 9303900573'
              }
            ],
            prizeCategories: [],
            prizeBreakdown: {
              '30kg - 1st': '₹ 50,000',
              '30kg - 2nd': '₹ 35,000',
              '30kg - 3rd': '₹ 25,000',
              '15kg - 1st': '₹ 40,000',
              '15kg - 2nd': '₹ 30,000',
              '15kg - 3rd': '₹ 20,000'
            },
            redirectUrl: 'https://unstop.com/p/robowars-iit-guwahati-1698835',
            rulebookUrl: 'https://forms.gle/3u7UQLV4v4szEH3WA'
          }
        ]
      },
      {
        title: 'Aquawars',
        imageAsset: 'assets/events/aquawars-reduced.jpg',
        events: [
          {
            title: 'Aquawars',
            subtitle: 'Naval Robotics & Aquatic Combat',
            category: 'Competitions',
            imageAsset: 'assets/events/aquawars-reduced.jpg',
            prizePool: '₹ 5,00,000',
            teamSize: 'Team Event',
            date: '29-08-2026 - 30-08-2026',
            time: '10:00 AM - 5:00 PM',
            venue: 'Water Arena, IIT Guwahati',
            description: 'Dive into the action-packed world of Aqua Wars, an electrifying game that combines the thrill of robotics with the challenge of aquatic battles.',
            rounds: [],
            rules: [
              'Water surface robot with high speed, manoeuvrability, and water turbulence stability.',
              'Must engage in battle with opponent robots.',
              'Team leader must add members using Techniche T_ID after Unstop registration.'
            ],
            prizeBreakdown: {
              'Winner': 'Rs. 2,00,000',
              '1st Runner Up': 'Rs. 1,50,000',
              '2nd Runner Up': 'Rs. 1,00,000',
              'Most Unique Design': 'Rs. 25,000',
              'Exceptional Bot': 'Rs. 25,000'
            },
            coordinators: [
              {
                name: 'Vomeshwar',
                role: 'Coordinator',
                phone: '+91 9303900573'
              }
            ],
            redirectUrl: 'https://unstop.com/o/0Dn74Co?lb=VYBEMRf&utm_medium=Share&utm_source=WhatsApp',
            rulebookUrl: 'https://forms.gle/3u7UQLV4v4szEH3WA'
          }
        ]
      },
      {
        title: 'Escalade',
        imageAsset: 'assets/events/exclade-reduced.jpg',
        events: [
          {
            title: 'Escalade',
            subtitle: 'Escalade 15.0 - Flagship National Robotics Competition',
            category: 'Competitions',
            imageAsset: 'assets/events/exclade-reduced.jpg',
            prizePool: '₹ 1,40,000',
            teamSize: 'Team Event',
            date: '28-08-2026 - 29-08-2026',
            time: '11:00 AM - 4:00 PM',
            venue: 'Auditorium Complex, IIT Guwahati',
            description: 'Escalade, the flagship National Robotics Competition organized by the Robotics module of Techniche, is the largest and fastest-growing robotics event in the northeast.',
            rounds: [],
            prizeBreakdown: {
              'Winner': 'Rs. 70,000',
              '1st Runner Up': 'Rs. 40,000',
              '2nd Runner Up': 'Rs. 30,000'
            },
            coordinators: [
              {
                name: 'Harsha',
                role: 'Coordinator',
                phone: '+91 8822350266'
              }
            ],
            redirectUrl: 'https://unstop.com/competitions/escalade-150-escalade-150-iit-guwahati-1667939',
            rulebookUrl: 'https://forms.gle/3u7UQLV4v4szEH3WA'
          }
        ]
      },
      {
        title: 'Track Titans',
        imageAsset: 'assets/events/tracktitians.png',
        events: [
          {
            title: 'Track Titans',
            subtitle: 'High-Performance RC Car Racing & Endurance',
            category: 'Competitions',
            imageAsset: 'assets/events/tracktitians.png',
            prizePool: '₹ 90,000',
            teamSize: 'Team Event',
            date: '29-08-2026',
            time: '9:30 AM - 3:30 PM',
            venue: 'SAC Building, IIT Guwahati',
            description: 'Track Titans challenges participants to design and build remote-controlled cars with exceptional speed, agility, and endurance.',
            rounds: [],
            prizeBreakdown: {
              '1st Place': 'Rs. 40,000',
              '2nd Place': 'Rs. 30,000',
              '3rd Place': 'Rs. 20,000'
            },
            coordinators: [
              {
                name: 'Sonam',
                role: 'Coordinator',
                phone: '+91 8955264342'
              }
            ],
            redirectUrl: 'https://unstop.com/p/track-titans-iit-guwahati-1699196',
            rulebookUrl: 'https://forms.gle/3u7UQLV4v4szEH3WA'
          }
        ]
      },
      {
        title: 'LineQuest',
        imageAsset: 'assets/micro.png',
        events: [
          {
            title: 'LineQuest',
            subtitle: 'Autonomous Line Maze Navigation Challenge',
            category: 'Competitions',
            imageAsset: 'assets/micro.png',
            prizePool: '₹ 70,000',
            teamSize: 'Team Event',
            date: '29-08-2026',
            time: '2:00 PM - 6:00 PM',
            venue: 'Core 1 Hall, IIT Guwahati',
            description: 'Line Quest is Techniche IIT Guwahati\'s flagship autonomous line-following challenge where innovation meets speed, precision, and intelligent decision-making.',
            rounds: [],
            prizeBreakdown: {
              'Winner': 'Rs. 35,000',
              '1st Runner Up': 'Rs. 20,000',
              '2nd Runner Up': 'Rs. 15,000'
            },
            coordinators: [
              {
                name: 'Sonam',
                role: 'Coordinator',
                phone: '+91 8955264342'
              }
            ],
            redirectUrl: 'https://forms.gle/3u7UQLV4v4szEH3WA',
            rulebookUrl: 'https://forms.gle/3u7UQLV4v4szEH3WA'
          }
        ]
      },
      {
        title: 'Funniche',
        imageAsset: 'assets/events/funniche-reduced.jpg',
        events: [
          {
            title: 'BGMI',
            subtitle: 'Battlegrounds Mobile India Championship',
            category: 'Funniche',
            imageAsset: 'assets/events/funniche-reduced.jpg',
            prizePool: '₹ 35,000',
            teamSize: '4 Players (Squad)',
            date: '04-09-2026 - 05-09-2026',
            time: '4:00 PM Onwards',
            venue: 'SAC Gaming Arena / Online',
            description: 'Squad up for the most intense battle royale esports tournament of Techniche.',
            rules: [
              'Only mobile devices are allowed (No emulators, iPad, or tablet devices).',
              'Maps: Erangel, Miramar, Sanhok in TPP Squad mode.',
              'Scoring is based on standard official BGIS point matrix.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 20,000',
              '2nd Place': '₹ 10,000',
              '3rd Place': '₹ 5,000'
            },
            coordinators: [
              {
                name: 'Arjun Das',
                role: 'Esports Head',
                phone: '+91 99887 76655'
              }
            ],
            redirectUrl: 'https://unstop.com/esports/bgmi-techniche-2026'
          },
          {
            title: 'Valorant',
            subtitle: '5v5 Tactical FPS Showdown',
            category: 'Funniche',
            imageAsset: 'assets/events/funniche-reduced.jpg',
            prizePool: '₹ 45,000',
            teamSize: '5 Players (+1 Sub)',
            date: '05-09-2026 - 06-09-2026',
            time: '11:00 AM Onwards',
            venue: 'Computer Center LAN Arena, IITG',
            description: 'Lock in your duelists, initiate executes, and outplay your opponents in the Premier Techniche Valorant LAN tournament.',
            rules: [
              'Tournament mode with standard map veto system.',
              'Matches are Best of 1 until Semi-Finals, Finals are Best of 3.',
              'Vanguard anti-cheat and tournament lobby rules apply.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 25,000',
              '2nd Place': '₹ 13,000',
              '3rd Place': '₹ 7,000'
            },
            coordinators: [
              {
                name: 'Siddharth Joshi',
                role: 'Valorant Lead',
                phone: '+91 98765 00112'
              }
            ],
            redirectUrl: 'https://unstop.com/esports/valorant-techniche-2026'
          },
          {
            title: 'Chess',
            subtitle: 'Rapid & Blitz Strategic Tournament',
            category: 'Funniche',
            imageAsset: 'assets/events/funniche-reduced.jpg',
            prizePool: '₹ 20,000',
            teamSize: 'Individual (1 Player)',
            date: '05-09-2026',
            time: '10:00 AM',
            venue: 'Conference Hall, Old SAC',
            description: 'FIDE-rated swiss-style chess championship testing strategic acumen, tactical calculation, and endgame mastery.',
            rules: [
              'Time control: 10 mins + 5 seconds increment per move.',
              'FIDE rules and standard touch-move rules apply strictly.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 10,000',
              '2nd Place': '₹ 6,000',
              '3rd Place': '₹ 4,000'
            },
            coordinators: [
              {
                name: 'Naman Jain',
                role: 'Chess Convener',
                phone: '+91 97766 55443'
              }
            ],
            redirectUrl: 'https://unstop.com/competitions/chess-techniche-2026'
          },
          {
            title: 'Smash Karts',
            subtitle: 'Fast-Paced 3D Arcade Kart Battle',
            category: 'Funniche',
            imageAsset: 'assets/events/funniche-reduced.jpg',
            prizePool: '₹ 15,000',
            teamSize: 'Individual (1 Player)',
            date: '06-09-2026',
            time: '3:00 PM',
            venue: 'SAC Lounge, IIT Guwahati',
            description: 'Grab power-ups, fire rockets, and drift through chaotic multiplayer kart battles to climb the leaderboard.',
            rules: [
              'Free-For-All deathmatch rounds.',
              'Top scorers from each heat advance to the Grand Finale.'
            ],
            prizeBreakdown: {
              '1st Place': '₹ 8,000',
              '2nd Place': '₹ 4,500',
              '3rd Place': '₹ 2,500'
            },
            coordinators: [
              {
                name: 'Tanmay Saxena',
                role: 'Coordinator',
                phone: '+91 95544 33221'
              }
            ],
            redirectUrl: 'https://unstop.com/esports/smash-karts-techniche-2026'
          }
        ]
      },
      {
        title: 'STPI',
        imageAsset: 'assets/stpi.jpg',
        events: []
      },
      {
        title: 'CatalysisT',
        imageAsset: 'assets/events/catalysisT.png',
        events: []
      },
      {
        title: 'Technothlon',
        imageAsset: 'assets/techno.png',
        events: [
          {
            title: 'Junior Squad',
            subtitle: 'Logic & Aptitude Olympiad for Classes 9 & 10',
            category: 'Technothlon',
            imageAsset: 'assets/techno.png',
            prizePool: '₹ 1,00,000 + Medals',
            teamSize: '2 Students',
            date: '05-09-2026',
            time: '9:00 AM - 1:00 PM',
            venue: 'Lecture Hall Complex, IIT Guwahati',
            description: 'Technothlon Junior Squad is the ultimate test of logical reasoning, mental agility, and intuitive problem-solving for school students from classes 9 and 10.',
            rules: [
              'Teams must consist of exactly 2 students from the same or different schools.',
              'No syllabus or rote learning required; questions test pure logic and creativity.'
            ],
            prizeBreakdown: {
              '1st Place (AIR 1)': '₹ 50,000 + Gold Medals',
              '2nd Place (AIR 2)': '₹ 30,000 + Silver Medals',
              '3rd Place (AIR 3)': '₹ 20,000 + Bronze Medals'
            },
            coordinators: [
              {
                name: 'Technothlon Team',
                role: 'Overall Coordinators',
                phone: '+91 98765 43210',
                email: 'technothlon@techniche.org.in'
              }
            ],
            redirectUrl: 'https://technothlon.techniche.org.in'
          },
          {
            title: 'Hauts Squad',
            subtitle: 'Advanced Logic & Critical Thinking for Classes 11 & 12',
            category: 'Technothlon',
            imageAsset: 'assets/techno.png',
            prizePool: '₹ 1,00,000 + Medals',
            teamSize: '2 Students',
            date: '05-09-2026',
            time: '2:00 PM - 6:00 PM',
            venue: 'Lecture Hall Complex, IIT Guwahati',
            description: 'Technothlon Hauts Squad challenges senior high-school minds with groundbreaking puzzles, algorithmic deduction, and cryptic mathematical reasoning.',
            rules: [
              'Teams must consist of exactly 2 students from classes 11 or 12.',
              'Top teams qualify for the Grand Finale held on IIT Guwahati campus.'
            ],
            prizeBreakdown: {
              '1st Place (AIR 1)': '₹ 50,000 + Gold Medals',
              '2nd Place (AIR 2)': '₹ 30,000 + Silver Medals',
              '3rd Place (AIR 3)': '₹ 20,000 + Bronze Medals'
            },
            coordinators: [
              {
                name: 'Technothlon Team',
                role: 'Overall Coordinators',
                phone: '+91 98765 43210',
                email: 'technothlon@techniche.org.in'
              }
            ],
            redirectUrl: 'https://technothlon.techniche.org.in'
          }
        ]
      }
    ]
  },
  {
    title: 'Workshops',
    subCategories: [
      {
        title: "Bioinformatics & Cancer Research Workshop",
        imageAsset: 'assets/workshops/world-technocon-bioinformatics-cancer-research.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/bioinformatics-and-cancer-research-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "CRISPR in Computational Genomics Workshop",
        imageAsset: 'assets/workshops/world-technocon-crispr-in-computational-genomics.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/quantum-computing-basics-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Human Resource Mastery Workshop",
        imageAsset: 'assets/workshops/world-technocon-human-resource-mastery-from-fundamentals.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/human-resource-mastery-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Generative AI Masterclass (17+ AI Tools)",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-masterclass-master-17.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/generative-ai-masterclass-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Data Science Mastery",
        imageAsset: 'assets/workshops/world-technocon-data-science-mastery-3.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/data-science-mastery-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "AI in Film and Reels Making Workshop",
        imageAsset: 'assets/workshops/world-technocon-ai-in-film-and-reels-making-copy-mrx4ey73.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ai-in-film-and-reels-making-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Diabetology & Metabolic Disorders",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-chatgpt-mastery-2.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/diabetology-and-metabolic-disorders-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Claude For Non-Technical Professionals",
        imageAsset: 'assets/workshops/world-technocon-claude-for-non-technical-professionals.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/claude-for-non-technical-professionals-workshop-at-visvesvaraya-national-institute-of-technology"
          }
        ]
      },
      {
        title: "Agentic AI Masterclass",
        imageAsset: 'assets/workshops/world-technocon-agentic-ai-masterclass-3-copy-mrx4eu55.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/agentic-ai-masterclass-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Innovation & Startup Ideas",
        imageAsset: 'assets/workshops/world-technocon-innovation-startup-ideas-2.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/innovation-startup-ideas-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Digital Marketing with Instagram Meta Ads",
        imageAsset: 'assets/workshops/world-technocon-digital-marketing-with-google-ads-and-seo.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/digital-marketing-google-ads-seo-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "AI in Drug Discovery Workshop",
        imageAsset: 'assets/workshops/world-technocon-ai-in-drug-discovery.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ai-for-healthcare-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Digital Marketing With Google Ads & SEO",
        imageAsset: 'assets/workshops/world-technocon-google-ads-seo-mastery-2.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/digital-marketing-mastery-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "UX Design with AI",
        imageAsset: 'assets/workshops/world-technocon-ux-design-with-ai-3.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ux-design-with-ai-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Entrepreneurship Essentials",
        imageAsset: 'assets/workshops/world-technocon-innovation-startup-ideas-2.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/entrepreneurship-essentials-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Ethical Hacking & Cyber Security Workshop",
        imageAsset: 'assets/workshops/world-technocon-agentic-ai-masterclass-3-copy-mrx4eu55.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ethical-hacking-cyber-security-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Fashion Design & Entrepreneurship",
        imageAsset: 'assets/workshops/world-technocon-ux-design-with-ai-3.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/fashion-design-entrepreneurship-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "AI & ML Fundamentals Workshop",
        imageAsset: 'assets/workshops/world-technocon-data-science-mastery-3.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/aiml-fundamentals-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Interior Design Basics & Entrepreneurship",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-masterclass-master-17.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/interior-design-entrepreneurship-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "Drone Building Workshop",
        imageAsset: 'assets/workshops/world-technocon-bioinformatics-cancer-research.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/drone-building-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "No-Code App Development using AI / Vibe Coding",
        imageAsset: 'assets/workshops/world-technocon-generative-ai-chatgpt-mastery-2.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/no-code-app-development-ai-workshop-at-iit-guwahati-august-2026"
          }
        ]
      },
      {
        title: "AI for Healthcare Professionals Workshop",
        imageAsset: 'assets/workshops/world-technocon-ai-in-drug-discovery.webp',
        events: [
          {
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
            redirectUrl: "https://technocon.org/events/iit-guwahati-august-2026/ai-for-hr-professionals-workshop-at-iit-guwahati-august-2026"
          }
        ]
      }
    ]
  },
  {
    title: 'Exhibitions',
    subCategories: [
      {
        title: 'Tech-Expo',
        imageAsset: 'assets/events/techexpo-reduced.jpg',
        events: [
          {
            title: 'Tech-Expo (Juniors)',
            subtitle: 'School Innovations & Science Showcase',
            category: 'Exhibitions',
            imageAsset: 'assets/events/techexpo-reduced.jpg',
            prizePool: '₹ 50,000',
            teamSize: '1 - 4 Students',
            date: '29-08-2026',
            time: '9:00 AM - 5:00 PM',
            venue: 'Exhibition Hall A, IIT Guwahati',
            description: 'An esteemed platform for young school innovators to showcase working scientific models, green technology prototypes, and engineering inventions.'
          },
          {
            title: 'Tech-Expo (Seniors)',
            subtitle: 'National Research & College Innovation Showcase',
            category: 'Exhibitions',
            imageAsset: 'assets/events/techexpo-reduced.jpg',
            prizePool: '₹ 1,50,000',
            teamSize: '1 - 5 Members',
            date: '29-08-2026',
            time: '9:00 AM - 5:00 PM',
            venue: 'Exhibition Hall B, IIT Guwahati',
            description: 'Showcase cutting-edge academic research projects, hardware patents, and deep-tech prototypes to renowned scientists, investors, and industrial leaders.'
          }
        ]
      },
      {
        title: 'Army Expo',
        imageAsset: 'assets/army-expo.jpg',
        events: [
          {
            title: 'Indian Army Weapons Showcase',
            subtitle: 'Defense Technology & Weaponry Exhibition',
            category: 'Exhibitions',
            imageAsset: 'assets/army-expo.jpg',
            date: '28-08-2026',
            time: '10:00 AM - 4:00 PM',
            venue: 'Main Helipad Grounds, IIT Guwahati',
            description: 'Experience state-of-the-art defense technology, artillery, tactical communication gear, and specialized military vehicles presented directly by the Indian Army.'
          }
        ]
      },
      {
        title: 'Road Show',
        imageAsset: 'assets/road-show.webp',
        events: [
          {
            title: 'Supercars & Superbikes Showcase',
            subtitle: 'Fleet of Roadsters Roaring in Campus',
            category: 'Exhibitions',
            imageAsset: 'assets/road-show.webp',
            date: '29-08-2026',
            time: '4:00 PM - 6:00 PM',
            venue: 'Core 1 Boulevard, IIT Guwahati',
            description: 'Witness an electrifying collection of exotic supercars, vintage classics, custom superbikes, and high-performance racing beasts revving through the campus.'
          }
        ]
      }
    ]
  },
  {
    title: 'Lecture Series',
    subCategories: [
      {
        title: 'Mr. Ashneer Grover',
        imageAsset: 'assets/events/lectureSeries-reduced.jpg',
        events: [
          {
            title: 'Keynote by Mr. Ashneer Grover',
            subtitle: 'Entrepreneurship, Fintech & Startup Ecosystem',
            category: 'Lecture Series',
            imageAsset: 'assets/events/lectureSeries-reduced.jpg',
            venue: 'Main Auditorium, IIT Guwahati',
            date: '05-09-2026',
            time: '5:00 PM',
            description: 'Candid talk on building hyper-scale fintech companies, disrupting Indian retail payments, venture investments, and founder resilience.'
          }
        ]
      },
      {
        title: 'Mr. PushkarRaj Salunke',
        imageAsset: 'assets/revamp.jpg',
        events: [
          {
            title: 'Keynote by Mr. PushkarRaj Salunke',
            subtitle: 'From Transformable EVs to Redefining Mobility',
            category: 'Lecture Series',
            imageAsset: 'assets/revamp.jpg',
            venue: 'Main Auditorium, IIT Guwahati',
            date: '06-09-2026',
            time: '11:00 AM',
            description: 'Insights into EV engineering, modular chassis design, manufacturing innovation, and the future of clean urban mobility in India.'
          }
        ]
      },
      {
        title: 'Mr. Dinesh Sharma',
        imageAsset: 'assets/asus.jpg',
        events: [
          {
            title: 'Keynote by Mr. Dinesh Sharma',
            subtitle: 'The Powerhouse Behind ASUS India’s Growth',
            category: 'Lecture Series',
            imageAsset: 'assets/asus.jpg',
            venue: 'Main Auditorium, IIT Guwahati',
            date: '06-09-2026',
            time: '3:00 PM',
            description: 'Exploring consumer tech innovations, gaming ecosystem growth in India, and leadership strategies in competitive global tech brands.'
          }
        ]
      }
    ]
  },
  {
    title: 'Nexus',
    subCategories: [
      {
        title: 'Conference',
        imageAsset: 'assets/events/nexus1.png',
        events: [
          {
            title: 'Nexus Conference',
            subtitle: 'Connect with Industry Leaders & Pioneer Thinkers',
            category: 'Nexus',
            imageAsset: 'assets/events/nexus1.png',
            date: '29-08-2026',
            time: '9:00 AM - 12:00 PM',
            venue: 'Conference Hall, IIT Guwahati',
            description: 'Exclusive flagship conference uniting visionary startup founders, researchers, venture capitalists, and industry leaders for groundbreaking keynotes and panel discussions.'
          }
        ]
      },
      {
        title: 'Hackathon',
        imageAsset: 'assets/events/nexusHackathon.png',
        events: [
          {
            title: 'Nexus Hackathon',
            subtitle: 'High-Stakes Technical Innovation & Hackathon',
            category: 'Nexus',
            imageAsset: 'assets/events/nexusHackathon.png',
            date: '29-08-2026 - 30-08-2026',
            time: '24 Hours',
            venue: 'Computer Center, IIT Guwahati',
            description: 'Intense multi-track hackathon challenging developers and designers to build transformative tech solutions addressing real-world corporate challenges.'
          }
        ]
      }
    ]
  },
  {
    title: 'Initiatives',
    subCategories: [
      {
        title: 'Guwahati Half Marathon',
        imageAsset: 'assets/ghm.png',
        events: [
          {
            title: 'Blood Donation Drive',
            subtitle: 'Saving Lives Across Northeast India',
            category: 'Initiatives',
            imageAsset: 'assets/ghm.png',
            date: '28-08-2026',
            time: '9:00 AM - 4:00 PM',
            venue: 'IIT Guwahati Hospital Complex',
            description: 'Join Techniche in our mission to support local healthcare centers and save lives through a mega blood donation campaign in collaboration with GMCH.'
          },
          {
            title: 'Food Distribution',
            subtitle: 'Zero Hunger Community Initiative',
            category: 'Initiatives',
            imageAsset: 'assets/ghm.png',
            date: '29-08-2026',
            time: '10:00 AM - 2:00 PM',
            venue: 'Guwahati City & Neighboring Villages',
            description: 'Techniche’s social initiative aimed at redistributing meals and groceries to underprivileged communities and orphanages.'
          }
        ]
      }
    ]
  }
];

async function seedHelpAndEvents() {
  console.log('🚀 Starting seeding process for Help Center and Event Categories...');
  const batch = db.batch();

  // 1. Seed Help Center Data to app_config/help_center
  const helpCenterRef = db.collection('app_config').doc('help_center');
  batch.set(helpCenterRef, {
    ...helpCenterData,
    updatedAt: FieldValue.serverTimestamp()
  }, { merge: true });
  console.log('  ➕ Staged: app_config/help_center');

  // 2. Seed Event Categories to event_categories/{id}
  for (const category of eventCategories) {
    const docId = category.title.toLowerCase().replace(/\s+/g, '_');
    const categoryRef = db.collection('event_categories').doc(docId);
    batch.set(categoryRef, {
      ...category,
      updatedAt: FieldValue.serverTimestamp()
    }, { merge: true });
    console.log(`  ➕ Staged: event_categories/${docId} (${category.title})`);
  }

  try {
    await batch.commit();
    console.log('\n🎉 Successfully seeded Help Center config and all Event Categories to Firestore!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Batch commit failed:', error);
    process.exit(1);
  }
}

seedHelpAndEvents();
