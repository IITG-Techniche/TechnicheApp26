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
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Robowars'),
          EventDetail(title: 'Aquawars'),
          EventDetail(title: 'UDCV'),
          EventDetail(title: 'Track Titans'),
        ],
      ),
      SubCategory(
        title: 'Funniche',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'BGMI'),
          EventDetail(title: 'Valorant'),
          EventDetail(title: 'Chess'),
        ],
      ),
      SubCategory(
        title: 'Corporate',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Case Study'),
          EventDetail(title: 'Business Plan'),
        ],
      ),
      SubCategory(
        title: 'TechOlympics',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Coding Challenge'),
          EventDetail(title: 'Math Olympiad'),
        ],
      ),
      SubCategory(
        title: 'TechExpo',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Innovation Showcase'),
          EventDetail(title: 'Startup Pitch'),
        ],
      ),
      SubCategory(
        title: 'Technothlon',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Junior Squad'),
          EventDetail(title: 'Senior Squad'),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Workshops',
    subCategories: [
      SubCategory(
        title: 'Software Development',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Full Stack with MERN'),
          EventDetail(title: 'Prompt Engineering'),
        ],
      ),
      SubCategory(
        title: 'Cyber Security',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Ethical Hacking 101'),
          EventDetail(title: 'Network Security'),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Exhibitions',
    subCategories: [
      SubCategory(
        title: 'Art & Culture',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Art Showcase'),
          EventDetail(title: 'Cultural Exhibition'),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Lecture Series',
    subCategories: [
      SubCategory(
        title: 'Tech Talks',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'AI in 2025'),
          EventDetail(title: 'The Future of Space Travel'),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Nexus',
    subCategories: [
      SubCategory(
        title: 'Networking Events',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Startup Meet'),
          EventDetail(title: 'Investor Pitch'),
        ],
      ),
    ],
  ),
  MainCategory(
    title: 'Initiatives',
    subCategories: [
      SubCategory(
        title: 'Social Impact',
        imageAsset: 'assets/aqua.png',
        events: const [
          EventDetail(title: 'Clean Energy Drive'),
          EventDetail(title: 'Community Upliftment'),
        ],
      ),
    ],
  ),
];
