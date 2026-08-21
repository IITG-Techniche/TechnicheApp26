class HelpContact {
  final String name;
  final String number;
  final String? timeSlot;

  const HelpContact({
    required this.name,
    required this.number,
    this.timeSlot,
  });
}

class HelpFaq {
  final String question;
  final String answer;

  const HelpFaq({
    required this.question,
    required this.answer,
  });
}

class HelpSocialLink {
  final String name;
  final String handle;
  final String url;
  final String iconAsset;

  const HelpSocialLink({
    required this.name,
    required this.handle,
    required this.url,
    required this.iconAsset,
  });
}

/// ============================================================================
/// 📚 TECHNICHE HELP CENTER DATA BANK
/// ============================================================================
/// You can easily edit, add, or update any contact numbers, hospitality heads,
/// transport buggy / e-rickshaw time slots, FAQs, and social links below anytime!
/// ============================================================================
class HelpCenterData {
  // ── 1. Hospital Contacts ──
  static const List<HelpContact> hospitalContacts = [
    HelpContact(name: 'Ambulance', number: '3612586666'),
    HelpContact(name: 'Reception', number: '3612585555'),
  ];

  // ── 2. Accommodation & Hospitality Contacts ──
  static const List<HelpContact> accommodationContacts = [
    HelpContact(name: 'Hospitality Head (Uday)', number: '9075438210'),
    HelpContact(name: 'Hospitality Head (Raghav)', number: '9075438210'),
    HelpContact(name: 'Hospitality Head (Vibha)', number: '9075438210'),
  ];

  // ── 3. Transport (Buggy & E-Rickshaw) Contacts & Time Slots ──
  static const List<HelpContact> transportContacts = [
    HelpContact(name: 'Buggy', number: '9213546678', timeSlot: '9:00-12:00'),
    HelpContact(name: 'Erickshaw 1', number: '6001440472', timeSlot: '8:00-14:00'),
    HelpContact(name: 'Erickshaw 2', number: '7896513761', timeSlot: '12:00-18:00'),
    HelpContact(name: 'Erickshaw 3', number: '8486664856', timeSlot: '16:00-22:00'),
    HelpContact(name: 'Erickshaw 4', number: '9123456780', timeSlot: '8:00-20:00'),
    HelpContact(name: 'Erickshaw 5', number: '9876543210', timeSlot: '8:00-20:00'),
  ];

  // ── 4. Frequently Asked Questions (FAQs) ──
  static const List<HelpFaq> faqs = [
    HelpFaq(
      question: 'How do i register for events?',
      answer:
          'Visit the official website (techniche.org.in) or click on any event in the app to view details and register directly on Unstop.',
    ),
    HelpFaq(
      question: 'Where can i find the event schedule?',
      answer:
          'The complete event schedule with date-wise filtering, live venue navigation, and timing is available under the Schedule tab.',
    ),
    HelpFaq(
      question: 'Is accomodation provided?',
      answer:
          'Hostel accommodation is available on campus for registered participants on a first-come, first-served basis. Please contact the Hospitality Team heads listed above.',
    ),
    HelpFaq(
      question: 'Who do i contact in case of emergency?',
      answer:
          'For any medical emergencies, call the IIT Guwahati Hospital Ambulance (0361-2586666) or the Security Reception immediately.',
    ),
    HelpFaq(
      question: 'How do I reach IIT Guwahati campus?',
      answer:
          'IIT Guwahati is located around 20 km from Guwahati Railway Station and 22 km from Lokpriya Gopinath Bordoloi International Airport. Institute buses and pre-paid taxis/autos are readily available.',
    ),
  ];

  // ── 5. Social Links (Instagram, LinkedIn, YouTube, X.com, Facebook) ──
  static const List<HelpSocialLink> socials = [
    HelpSocialLink(
      name: 'Instagram',
      handle: '@techniche_iitguwahati',
      url: 'https://www.instagram.com/techniche_iitguwahati/?hl=en',
      iconAsset: 'assets/instagram.png',
    ),
    HelpSocialLink(
      name: 'LinkedIn',
      handle: 'techniche-iitg',
      url: 'https://in.linkedin.com/company/techniche-iitg',
      iconAsset: 'assets/linkedin.png',
    ),
    HelpSocialLink(
      name: 'YouTube',
      handle: 'techniche',
      url: 'https://www.youtube.com/c/techniche',
      iconAsset: 'assets/youtube.png',
    ),
    HelpSocialLink(
      name: 'X.com',
      handle: '@Techniche_IITG',
      url: 'https://twitter.com/Techniche_IITG',
      iconAsset: 'assets/x.png',
    ),
    HelpSocialLink(
      name: 'Facebook',
      handle: 'techniche.iitguwahati',
      url: 'https://www.facebook.com/techniche.iitguwahati/',
      iconAsset: 'assets/facebook.png',
    ),
  ];
}
