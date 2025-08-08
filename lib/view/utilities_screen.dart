import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'landing_screen.dart' show AnimatedGradientBackground;

class UtilitiesScreen extends StatefulWidget {
  static const String routeName = '/utilities-screen';
  const UtilitiesScreen({Key? key}) : super(key: key);

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  bool showFAQ = false;
  bool showTeam = false;

  void _showContactsModal(String title, List<_Contact> contacts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...contacts.map((c) => ListTile(
                  leading: const Icon(Icons.contact_phone),
                  title: Text(c.name),
                  subtitle: Text(c.number),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () async {
                      final Uri url = Uri.parse('tel:${c.number}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_Contact> hospitalContacts = const [
      _Contact(name: 'Emergency', number: '102'),
      _Contact(name: 'Hospital Reception', number: '+91-361-2582099'),
    ];
    final List<_Contact> transportContacts = const [
      _Contact(name: 'E-Rickshaw 1', number: '+91-600-1440472'),
      _Contact(name: 'E-Rickshaw 2', number: '+91-789-6513761'),
      _Contact(name: 'E-Rickshaw 3', number: '+91-848-6664856'),
    ];
    final List<_Contact> hospitalityContacts = const [
      _Contact(name: 'Hospitality Head (Uday)', number: '+91-90754-38210'),
      _Contact(name: 'Hospitality Head (Raghav)', number: '+91-98173-37227'),
      _Contact(name: 'Hospitality Head (Savi)', number: '+91-90090-49368'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Utilities & Contacts'),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Quick Contacts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ModalUtilityIcon(
                        icon: Icons.local_hospital,
                        label: 'IITG Hospital',
                        contacts: hospitalContacts,
                        onTap: () => _showContactsModal(
                            'IITG Hospital', hospitalContacts),
                      ),
                      _ModalUtilityIcon(
                        icon: Icons.local_shipping,
                        label: 'Transport',
                        contacts: transportContacts,
                        onTap: () =>
                            _showContactsModal('Transport', transportContacts),
                      ),
                      _ModalUtilityIcon(
                        icon: Icons.hotel,
                        label: 'Hospitality',
                        contacts: hospitalityContacts,
                        onTap: () => _showContactsModal(
                            'Hospitality', hospitalityContacts),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // FAQ Section
                  ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: const Text('FAQ'),
                    trailing:
                        Icon(showFAQ ? Icons.expand_less : Icons.expand_more),
                    onTap: () => setState(() => showFAQ = !showFAQ),
                  ),
                  if (showFAQ) ...[
                    const _FAQList(),
                    const Divider(),
                  ],
                  // Team Section
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Team'),
                    trailing:
                        Icon(showTeam ? Icons.expand_less : Icons.expand_more),
                    onTap: () => setState(() => showTeam = !showTeam),
                  ),
                  if (showTeam) ...[
                    const _TeamList(),
                    const Divider(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalUtilityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<_Contact> contacts;
  final VoidCallback onTap;

  const _ModalUtilityIcon({
    Key? key,
    required this.icon,
    required this.label,
    required this.contacts,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.1),
            ),
            child: Icon(icon, size: 32, color: Colors.blueAccent),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class ContactsScreen extends StatelessWidget {
  final String title;
  final List<_Contact> contacts;
  const ContactsScreen({required this.title, required this.contacts, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final c = contacts[i];
          return ListTile(
            leading: const Icon(Icons.contact_phone),
            title: Text(c.name),
            subtitle: Text(c.number),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _callNumber(c.number),
            ),
          );
        },
      ),
    );
  }

  Future<void> _callNumber(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Show error
    }
  }
}

class _FAQList extends StatelessWidget {
  const _FAQList({Key? key}) : super(key: key);

  final List<_FAQ> faqs = const [
    _FAQ(
      question: 'How do I register for events?',
      answer: 'Visit the Events section on the app and tap on Register.',
    ),
    _FAQ(
      question: 'Where can I find the event schedule?',
      answer: 'The schedule is available under the Schedule tab.',
    ),
    _FAQ(
      question: 'Is accommodation provided?',
      answer:
          'Hostel accommodation is limited. Please contact Hospitality Team.',
    ),
    _FAQ(
      question: 'Who do I contact in case of emergency?',
      answer: 'Use the IITG Hospital quick contact above.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      itemCount: faqs.length,
      itemBuilder: (_, i) {
        final f = faqs[i];
        return ExpansionTile(
          title: Text(f.question),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(f.answer),
            )
          ],
        );
      },
    );
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList({Key? key}) : super(key: key);

  final List<_TeamMember> members = const [
    _TeamMember(name: 'Alice - Convenor', imageUrl: 'assets/placeholder.png'),
    _TeamMember(
        name: 'Bob - Hospitality Head', imageUrl: 'assets/placeholder.png'),
    _TeamMember(
        name: 'Carol - Transport Head', imageUrl: 'assets/placeholder.png'),
    _TeamMember(name: 'Dave - Events Head', imageUrl: 'assets/placeholder.png'),
    _TeamMember(name: 'Eve - App Dev Lead', imageUrl: 'assets/placeholder.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final m = members[i];
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(m.imageUrl,
                  width: 100, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(m.name, textAlign: TextAlign.center),
          ],
        );
      },
    );
  }
}

class _Contact {
  final String name;
  final String number;
  const _Contact({required this.name, required this.number});
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}

class _TeamMember {
  final String name;
  final String imageUrl;
  const _TeamMember({required this.name, required this.imageUrl});
}
