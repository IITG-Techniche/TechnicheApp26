class EventDetail {
  final String title;
  final String? redirectUrl;
  const EventDetail({
    required this.title,
    this.redirectUrl,
  });
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
        title: 'Technothlon',
        imageAsset: 'assets/techno.png',
        events: const [
          EventDetail(title: 'Junior Squad'),
          EventDetail(title: 'Hauts Squad'),
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
              title: '',
              redirectUrl:
                  "https://unstop.com/workshops-webinars/full-stack-web-development-bootcamp-iit-guwahati-1541887"),
        ],
      ),
      SubCategory(
        title: 'Arduino Project Development',
        imageAsset: 'assets/arduino.jpg',
        events: const [
          EventDetail(
              title: '',
              redirectUrl:
                  "https://unstop.com/workshops-webinars/arduino-project-development-workshop-iit-guwahati-1541858"),
        ],
      ),
      SubCategory(
        title: 'Generative AI',
        imageAsset: 'assets/genai.jpg',
        events: const [
          EventDetail(
              title: '',
              redirectUrl:
                  "https://unstop.com/workshops-webinars/generative-ai-agentic-ai-workshop-iit-guwahati-1541805"),
        ],
      ),
      SubCategory(
        title: 'Cybersecurity',
        imageAsset: 'assets/cybersec.jpg',
        events: const [
          EventDetail(
              title: '',
              redirectUrl:
                  "https://unstop.com/workshops-webinars/cybersecurity-and-ethical-hacking-workshop-iit-guwahati-1541776"),
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
          EventDetail(title: 'Juniors'),
          EventDetail(title: 'Seniors'),
        ],
      ),
      SubCategory(
        title: 'Army Expo',
        imageAsset: 'assets/army-expo.jpg',
        events: const [
          EventDetail(title: 'Indian Army Weapons Showcase'),
        ],
      ),
      SubCategory(
        title: 'Road Show',
        imageAsset: 'assets/road-show.webp',
        events: const [
          EventDetail(title: 'Fleet of Roadsters Roaring in campus'),
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
          // EventDetail(title: 'Former manageing Director of BharatPe ')
        ],
      ),
      SubCategory(
        title: 'Mr. PushkarRaj Salunke',
        imageAsset: 'assets/revamp.jpg',
        events: const [
          // EventDetail(
          //     title:
          //         'From building India’s first transformable EVs to redefining mobility')
        ],
      ),
      SubCategory(
        title: 'Mr. Dinesh Sharma',
        imageAsset: 'assets/asus.jpg',
        events: const [
          //EventDetail(title: 'The powerhouse behind ASUS India’s success')
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
        imageAsset: 'assets/ghm.png',
        events: const [
          EventDetail(title: 'Blood Donation'),
          EventDetail(title: 'Food Distribution'),
        ],
      ),
    ],
  ),
];
