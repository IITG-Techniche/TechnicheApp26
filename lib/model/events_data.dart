class EventDetail {
  final String title;
  const EventDetail({required this.title});
}

class SubCategory {
  final String title;
  final String imageAsset; // Placeholder image path
  final List<EventDetail> events;

  const SubCategory({
    required this.title,
    required this.imageAsset,
    required this.events,
  });
}

class MainCategory {
  final String title;
  final List<SubCategory> subCategories;

  const MainCategory({
    required this.title,
    required this.subCategories,
  });
}

final List<MainCategory> eventData = [
  MainCategory(
    title: 'Competitions',
    subCategories: [
      SubCategory(
        title: 'Robotics',
        imageAsset: 'assets/robotics.jpeg',
        events: const [
          EventDetail(title: 'Robowars'),
          EventDetail(title: 'Aquawars'),
          EventDetail(title: 'UVDC'),
          EventDetail(title: 'Track Titans'),
          EventDetail(title: 'Micro Mouse'),
          EventDetail(title: 'Escalade'),
        ],
      ),
      SubCategory(
        title: 'Funniche',
        imageAsset: 'assets/funniche.png',
        events: const [
          EventDetail(title: 'BGMI'),
          EventDetail(title: 'Valorant'),
          EventDetail(title: 'Chess'),
          EventDetail(title: 'Smash Karts'),
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
          EventDetail(title: 'IoT in Agriculture'),
          EventDetail(title: 'Gaming & Entertainment'),
          EventDetail(title: 'AR/VR & Emerging Tech'),
          EventDetail(title: 'Data Analytics & AI'),
          EventDetail(title: 'Graphic Design & Animation'),
          EventDetail(title: 'GIS Applications'),
        ],
      ),
      SubCategory(
        title: 'CatalysisT',
        imageAsset: 'assets/cata.jpg',
        events: const [],
      ),
      SubCategory(
        title: 'Tech-Expo',
        imageAsset: 'assets/techexpo.jpg',
        events: const [
          EventDetail(title: 'Juniors'),
          EventDetail(title: 'Seniors'),
        ],
      ),
      SubCategory(
        title: 'Technothlon',
        imageAsset: 'assets/techno.png',
        events: const [
          EventDetail(title: 'Junior Squad'),
          EventDetail(title: 'Hauts Squad'),
        ],
      ),
    ],
  ),
  // MainCategory(
  //   title: 'Workshops',
  //   subCategories: [
  //     SubCategory(
  //       title: 'Software Development',
  //       imageAsset: 'assets/aqua.png',
  //       events: const [
  //         EventDetail(title: 'Full Stack'),
  //         EventDetail(title: 'Prompt Engineering'),
  //       ],
  //     ),
  //     SubCategory(
  //       title: 'Cyber Security',
  //       imageAsset: 'assets/aqua.png',
  //       events: const [
  //         EventDetail(title: 'Ethical Hacking 101'),
  //         EventDetail(title: 'Network Security'),
  //       ],
  //     ),
  //     SubCategory(
  //       title: 'AWS Workshop',
  //       imageAsset: 'assets/aqua.png',
  //       events: const [
  //         EventDetail(title: 'Server Handling Basics'),
  //         EventDetail(title: 'Cloud Infrastructure'),
  //       ],
  //     ),
  //   ],
  // ),
  // MainCategory(
  //   title: 'Exhibitions',
  //   subCategories: [
  //     SubCategory(
  //       title: 'Army Expo',
  //       imageAsset: 'assets/aqua.png',
  //       events: const [
  //         EventDetail(title: 'Indian Army Weapons Showcase'),
  //       ],
  //     ),
  //     SubCategory(
  //       title: 'Road Show',
  //       imageAsset: 'assets/aqua.png',
  //       events: const [
  //         EventDetail(title: 'Fleet of Roadsters Roaring in campus'),
  //       ],
  //     ),
  //   ],
  // ),
  // MainCategory(
  //   title: 'Lecture Series',
  //   subCategories: [
  //     SubCategory(
  //       title: 'Leadership',
  //       imageAsset: 'assets/aqua.png',
  //       events: const [
  //         EventDetail(title: 'Keynote'),
  //         EventDetail(title: 'Panel Discussion'),
  //       ],
  //     ),
  //   ],
  // ),
  MainCategory(
    title: 'Nexus',
    subCategories: [
      SubCategory(
        title: 'Networking Events',
        imageAsset: 'assets/nexus.png',
        events: const [
          EventDetail(title: 'Icebreaking & Keynote'),
          EventDetail(title: 'Live Project'),
          EventDetail(title: 'Mentorship'),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Initiatives',
    subCategories: [
      SubCategory(
        title: 'Guwahati Half Marathon',
        imageAsset: 'assets/ghm.jpg',
        events: const [
          EventDetail(title: 'Blood Donation'),
          EventDetail(title: 'Food Distribution'),
        ],
      ),
    ],
  ),
];
